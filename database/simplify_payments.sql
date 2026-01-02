-- Simplification du système de paiement
-- Un paiement par inscription, une seule fois, reste payé pour toujours

-- Supprimer les colonnes mensuelles qui ne sont plus nécessaires
ALTER TABLE payments DROP COLUMN IF EXISTS payment_month;
ALTER TABLE payments DROP COLUMN IF EXISTS payment_year;

-- Supprimer l'index unique mensuel
DROP INDEX IF EXISTS idx_payments_unique_monthly;
DROP INDEX IF EXISTS idx_payments_month_year;

-- Créer un index unique pour un seul paiement par inscription
CREATE UNIQUE INDEX IF NOT EXISTS idx_payments_unique_enrollment 
ON payments(enrollment_id);

-- Mettre à jour le statut par défaut
ALTER TABLE payments ALTER COLUMN payment_status SET DEFAULT 'unpaid';

-- Fonction simplifiée pour créer les paiements lors d'une nouvelle inscription
DROP FUNCTION IF EXISTS create_enrollment_payment();

CREATE FUNCTION create_enrollment_payment(p_enrollment_id UUID)
RETURNS UUID AS $$
DECLARE
    v_payment_id UUID;
    v_parent_id UUID;
    v_nursery_id UUID;
    v_child_id UUID;
    v_amount NUMERIC;
BEGIN
    -- Récupérer les informations de l'inscription
    SELECT 
        e.nursery_id,
        c.parent_id,
        e.child_id,
        COALESCE(n.price_per_month, 100.00)
    INTO v_nursery_id, v_parent_id, v_child_id, v_amount
    FROM enrollments e
    JOIN children c ON e.child_id = c.id
    JOIN nurseries n ON e.nursery_id = n.id
    WHERE e.id = p_enrollment_id;

    -- Créer le paiement
    INSERT INTO payments (
        enrollment_id, 
        parent_id, 
        nursery_id, 
        child_id, 
        amount, 
        payment_status
    )
    VALUES (
        p_enrollment_id,
        v_parent_id,
        v_nursery_id,
        v_child_id,
        v_amount,
        'unpaid'
    )
    RETURNING id INTO v_payment_id;
    
    RETURN v_payment_id;
END;
$$ LANGUAGE plpgsql;

-- Créer les paiements pour toutes les inscriptions acceptées qui n'ont pas encore de paiement
INSERT INTO payments (enrollment_id, parent_id, nursery_id, child_id, amount, payment_status)
SELECT 
    e.id,
    c.parent_id,
    e.nursery_id,
    e.child_id,
    COALESCE(n.price_per_month, 100.00),
    'unpaid'
FROM enrollments e
JOIN nurseries n ON e.nursery_id = n.id
JOIN children c ON e.child_id = c.id
WHERE e.status = 'accepted'
AND NOT EXISTS (
    SELECT 1 FROM payments p 
    WHERE p.enrollment_id = e.id
)
ON CONFLICT (enrollment_id) DO NOTHING;

-- Mettre à jour la vue
DROP VIEW IF EXISTS payment_details;

CREATE VIEW payment_details AS
SELECT 
    p.id,
    p.enrollment_id,
    p.parent_id,
    p.nursery_id,
    p.child_id,
    p.amount,
    p.payment_status,
    p.payment_date,
    p.card_last_digits,
    p.transaction_id,
    u.name as parent_name,
    u.email as parent_email,
    c.name as child_name,
    n.name as nursery_name,
    n.price_per_month
FROM payments p
JOIN users u ON p.parent_id = u.id
JOIN children c ON p.child_id = c.id
JOIN nurseries n ON p.nursery_id = n.id;

COMMENT ON TABLE payments IS 'Paiements uniques par inscription - reste payé pour toujours';
COMMENT ON COLUMN payments.payment_status IS 'Statut: paid ou unpaid (ne change jamais une fois payé)';

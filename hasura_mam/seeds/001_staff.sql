INSERT INTO public.staff (
    first_name, last_name, gender, mobile, email, password, is_active, joined_at, default_role
) VALUES
    ('畅', '舒', 'M', '18563950872', 'changshu.qd@gmail.com', 'sc', 'true', '2018-04-30 00:00:00+08', 'Administrator');

INSERT INTO public.staff_role(
    staff, role, created_by
) VALUES
    ((SELECT id from public.staff WHERE first_name='畅'), 'General_Manager', (SELECT id from public.staff WHERE first_name='畅')),
    ((SELECT id from public.staff WHERE first_name='畅'), 'Sales_Manager', (SELECT id from public.staff WHERE first_name='畅')),
    ((SELECT id from public.staff WHERE first_name='畅'), 'Inventory_Operator', (SELECT id from public.staff WHERE first_name='畅'));


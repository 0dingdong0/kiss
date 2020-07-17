CREATE FUNCTION public.encrypt_password_md5() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
NEW.password := MD5(NEW.password);
RETURN NEW;
END;
$$;
CREATE TABLE public.staff (
    id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    gender text NOT NULL,
    title text,
    ic_number text,
    mobile text,
    email text,
    password text,
    is_active boolean NOT NULL,
    joined_at timestamp with time zone DEFAULT now(),
    dismissed_at timestamp with time zone,
    default_role text
);
CREATE SEQUENCE public."User_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public."User_id_seq" OWNED BY public.staff.id;
CREATE TABLE public.gender (
    value text NOT NULL,
    comment text NOT NULL
);
CREATE TABLE public.role (
    value text NOT NULL,
    comment text
);
CREATE TABLE public.staff_role (
    staff integer NOT NULL,
    role text NOT NULL,
    created_by integer NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);
ALTER TABLE ONLY public.staff ALTER COLUMN id SET DEFAULT nextval('public."User_id_seq"'::regclass);
ALTER TABLE ONLY public.staff
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public.gender
    ADD CONSTRAINT gender_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_email_key UNIQUE (email);
ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_mobile_key UNIQUE (mobile);
ALTER TABLE ONLY public.staff_role
    ADD CONSTRAINT staff_role_pkey PRIMARY KEY (staff, role);
CREATE TRIGGER encrypt_password BEFORE INSERT OR UPDATE OF password ON public.staff FOR EACH ROW WHEN (((new.password IS NOT NULL) AND (length(new.password) <> 32))) EXECUTE FUNCTION public.encrypt_password_md5();
ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_default_role_fkey FOREIGN KEY (default_role) REFERENCES public.role(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_gender_fkey FOREIGN KEY (gender) REFERENCES public.gender(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.staff_role
    ADD CONSTRAINT staff_role_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.staff(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.staff_role
    ADD CONSTRAINT staff_role_role_fkey FOREIGN KEY (role) REFERENCES public.role(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.staff_role
    ADD CONSTRAINT staff_role_staff_fkey FOREIGN KEY (staff) REFERENCES public.staff(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

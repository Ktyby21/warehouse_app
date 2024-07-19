--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Postgres.app)
-- Dumped by pg_dump version 16.3

-- Started on 2024-07-19 02:03:58 CEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3799 (class 1262 OID 16450)
-- Name: test_db; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE test_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = icu LOCALE = 'en_US.UTF-8' ICU_LOCALE = 'en-US';


ALTER DATABASE test_db OWNER TO postgres;

\connect test_db

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 228 (class 1259 OID 16929)
-- Name: user_access_levels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_access_levels (
    access_level_id integer NOT NULL,
    access_level_name character varying(50) NOT NULL
);


ALTER TABLE public.user_access_levels OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16928)
-- Name: access_levels_access_level_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.access_levels_access_level_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.access_levels_access_level_id_seq OWNER TO postgres;

--
-- TOC entry 3800 (class 0 OID 0)
-- Dependencies: 227
-- Name: access_levels_access_level_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.access_levels_access_level_id_seq OWNED BY public.user_access_levels.access_level_id;


--
-- TOC entry 232 (class 1259 OID 16988)
-- Name: attendance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attendance (
    worker_id integer NOT NULL,
    attendance_date date NOT NULL,
    day_type character varying(10) NOT NULL,
    scheduled_start_time time without time zone,
    scheduled_end_time time without time zone,
    scheduled_work_hours numeric(10,2),
    actual_work_hours numeric(10,2),
    absence_reason character varying(255),
    break_time time without time zone
);


ALTER TABLE public.attendance OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16516)
-- Name: feedbacks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.feedbacks (
    feedback_id integer NOT NULL,
    feedback_date date NOT NULL,
    worker_id character varying(255),
    feedback_text text NOT NULL
);


ALTER TABLE public.feedbacks OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16515)
-- Name: feedbacks_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.feedbacks_feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.feedbacks_feedback_id_seq OWNER TO postgres;

--
-- TOC entry 3801 (class 0 OID 0)
-- Dependencies: 215
-- Name: feedbacks_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.feedbacks_feedback_id_seq OWNED BY public.feedbacks.feedback_id;


--
-- TOC entry 220 (class 1259 OID 16625)
-- Name: worker_firms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.worker_firms (
    firm_id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.worker_firms OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16624)
-- Name: firms_firm_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.firms_firm_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.firms_firm_id_seq OWNER TO postgres;

--
-- TOC entry 3802 (class 0 OID 0)
-- Dependencies: 219
-- Name: firms_firm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.firms_firm_id_seq OWNED BY public.worker_firms.firm_id;


--
-- TOC entry 226 (class 1259 OID 16844)
-- Name: message_group_list; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.message_group_list (
    group_id integer NOT NULL,
    group_name character varying(255) NOT NULL
);


ALTER TABLE public.message_group_list OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16843)
-- Name: groups_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.groups_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.groups_group_id_seq OWNER TO postgres;

--
-- TOC entry 3803 (class 0 OID 0)
-- Dependencies: 225
-- Name: groups_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.groups_group_id_seq OWNED BY public.message_group_list.group_id;


--
-- TOC entry 218 (class 1259 OID 16609)
-- Name: user_languages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_languages (
    language_id integer NOT NULL,
    code character varying(3) NOT NULL,
    name character varying(50)
);


ALTER TABLE public.user_languages OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16608)
-- Name: languages_language_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.languages_language_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.languages_language_id_seq OWNER TO postgres;

--
-- TOC entry 3804 (class 0 OID 0)
-- Dependencies: 217
-- Name: languages_language_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.languages_language_id_seq OWNED BY public.user_languages.language_id;


--
-- TOC entry 248 (class 1259 OID 17279)
-- Name: message_absence_records; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.message_absence_records (
    record_id integer NOT NULL,
    worker_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    message character varying(255) NOT NULL,
    sent_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    file_url character varying(255)
);


ALTER TABLE public.message_absence_records OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 17278)
-- Name: message_absence_records_record_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.message_absence_records_record_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.message_absence_records_record_id_seq OWNER TO postgres;

--
-- TOC entry 3805 (class 0 OID 0)
-- Dependencies: 247
-- Name: message_absence_records_record_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.message_absence_records_record_id_seq OWNED BY public.message_absence_records.record_id;


--
-- TOC entry 250 (class 1259 OID 17306)
-- Name: message_attachments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.message_attachments (
    attachment_id integer NOT NULL,
    message_id integer,
    file_path text,
    file_type text
);


ALTER TABLE public.message_attachments OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 17305)
-- Name: message_attachments_attachment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.message_attachments_attachment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.message_attachments_attachment_id_seq OWNER TO postgres;

--
-- TOC entry 3806 (class 0 OID 0)
-- Dependencies: 249
-- Name: message_attachments_attachment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.message_attachments_attachment_id_seq OWNED BY public.message_attachments.attachment_id;


--
-- TOC entry 244 (class 1259 OID 17221)
-- Name: message_recipients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.message_recipients (
    message_id integer NOT NULL,
    recipient_group_id integer,
    recipient_user_id integer
);


ALTER TABLE public.message_recipients OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 17206)
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    message_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    sender_id integer NOT NULL,
    has_attachments boolean DEFAULT false,
    title character varying(255) NOT NULL,
    message_content text
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 17205)
-- Name: messages_message_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.messages_message_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.messages_message_id_seq OWNER TO postgres;

--
-- TOC entry 3807 (class 0 OID 0)
-- Dependencies: 242
-- Name: messages_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.messages_message_id_seq OWNED BY public.messages.message_id;


--
-- TOC entry 241 (class 1259 OID 17189)
-- Name: process; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.process (
    process_entry_id integer NOT NULL,
    date date NOT NULL,
    worker_id integer NOT NULL,
    scanned_items integer NOT NULL,
    time_spent numeric(10,2) NOT NULL,
    process_id integer
);


ALTER TABLE public.process OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 17188)
-- Name: process_process_entry_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.process_process_entry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.process_process_entry_id_seq OWNER TO postgres;

--
-- TOC entry 3808 (class 0 OID 0)
-- Dependencies: 240
-- Name: process_process_entry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.process_process_entry_id_seq OWNED BY public.process.process_entry_id;


--
-- TOC entry 224 (class 1259 OID 16678)
-- Name: process_targets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.process_targets (
    target_id integer NOT NULL,
    process_id integer NOT NULL,
    target_date date NOT NULL,
    target_items_per_hour integer NOT NULL
);


ALTER TABLE public.process_targets OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16677)
-- Name: process_targets_target_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.process_targets_target_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.process_targets_target_id_seq OWNER TO postgres;

--
-- TOC entry 3809 (class 0 OID 0)
-- Dependencies: 223
-- Name: process_targets_target_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.process_targets_target_id_seq OWNED BY public.process_targets.target_id;


--
-- TOC entry 222 (class 1259 OID 16640)
-- Name: process_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.process_types (
    process_id integer NOT NULL,
    process_name character varying(20) NOT NULL
);


ALTER TABLE public.process_types OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16639)
-- Name: process_types_process_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.process_types_process_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.process_types_process_id_seq OWNER TO postgres;

--
-- TOC entry 3810 (class 0 OID 0)
-- Dependencies: 221
-- Name: process_types_process_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.process_types_process_id_seq OWNED BY public.process_types.process_id;


--
-- TOC entry 233 (class 1259 OID 17074)
-- Name: user_message_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_message_groups (
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.user_message_groups OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16938)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    worker_id integer NOT NULL,
    worker_login character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    access_level_id integer DEFAULT 1 NOT NULL,
    is_logged_in boolean DEFAULT false NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16937)
-- Name: users_worker_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_worker_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_worker_id_seq OWNER TO postgres;

--
-- TOC entry 3811 (class 0 OID 0)
-- Dependencies: 229
-- Name: users_worker_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_worker_id_seq OWNED BY public.users.worker_id;


--
-- TOC entry 235 (class 1259 OID 17152)
-- Name: worker_group_names; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.worker_group_names (
    group_name_id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.worker_group_names OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 17151)
-- Name: worker_group_names_group_name_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.worker_group_names_group_name_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.worker_group_names_group_name_id_seq OWNER TO postgres;

--
-- TOC entry 3812 (class 0 OID 0)
-- Dependencies: 234
-- Name: worker_group_names_group_name_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.worker_group_names_group_name_id_seq OWNED BY public.worker_group_names.group_name_id;


--
-- TOC entry 237 (class 1259 OID 17159)
-- Name: worker_group_numbers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.worker_group_numbers (
    group_number_id integer NOT NULL,
    number character varying(50) NOT NULL
);


ALTER TABLE public.worker_group_numbers OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 17158)
-- Name: worker_group_numbers_group_number_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.worker_group_numbers_group_number_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.worker_group_numbers_group_number_id_seq OWNER TO postgres;

--
-- TOC entry 3813 (class 0 OID 0)
-- Dependencies: 236
-- Name: worker_group_numbers_group_number_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.worker_group_numbers_group_number_id_seq OWNED BY public.worker_group_numbers.group_number_id;


--
-- TOC entry 231 (class 1259 OID 16955)
-- Name: worker_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.worker_info (
    worker_id integer NOT NULL,
    fullname character varying(255) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    last_messages_check timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    language_id integer DEFAULT 1 NOT NULL,
    firm_id integer DEFAULT 1,
    transport_id integer,
    group_name_id integer,
    group_number_id integer,
    location_id integer
);


ALTER TABLE public.worker_info OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 17267)
-- Name: worker_location_list; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.worker_location_list (
    location_id integer NOT NULL,
    location_name character varying(255) NOT NULL
);


ALTER TABLE public.worker_location_list OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 17266)
-- Name: worker_location_list_location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.worker_location_list_location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.worker_location_list_location_id_seq OWNER TO postgres;

--
-- TOC entry 3814 (class 0 OID 0)
-- Dependencies: 245
-- Name: worker_location_list_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.worker_location_list_location_id_seq OWNED BY public.worker_location_list.location_id;


--
-- TOC entry 239 (class 1259 OID 17166)
-- Name: worker_transport_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.worker_transport_types (
    transport_id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.worker_transport_types OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 17165)
-- Name: worker_transport_types_transport_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.worker_transport_types_transport_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.worker_transport_types_transport_id_seq OWNER TO postgres;

--
-- TOC entry 3815 (class 0 OID 0)
-- Dependencies: 238
-- Name: worker_transport_types_transport_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.worker_transport_types_transport_id_seq OWNED BY public.worker_transport_types.transport_id;


--
-- TOC entry 3556 (class 2604 OID 16519)
-- Name: feedbacks feedback_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedbacks ALTER COLUMN feedback_id SET DEFAULT nextval('public.feedbacks_feedback_id_seq'::regclass);


--
-- TOC entry 3578 (class 2604 OID 17282)
-- Name: message_absence_records record_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_absence_records ALTER COLUMN record_id SET DEFAULT nextval('public.message_absence_records_record_id_seq'::regclass);


--
-- TOC entry 3580 (class 2604 OID 17309)
-- Name: message_attachments attachment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_attachments ALTER COLUMN attachment_id SET DEFAULT nextval('public.message_attachments_attachment_id_seq'::regclass);


--
-- TOC entry 3561 (class 2604 OID 16847)
-- Name: message_group_list group_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_group_list ALTER COLUMN group_id SET DEFAULT nextval('public.groups_group_id_seq'::regclass);


--
-- TOC entry 3574 (class 2604 OID 17209)
-- Name: messages message_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages ALTER COLUMN message_id SET DEFAULT nextval('public.messages_message_id_seq'::regclass);


--
-- TOC entry 3573 (class 2604 OID 17192)
-- Name: process process_entry_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.process ALTER COLUMN process_entry_id SET DEFAULT nextval('public.process_process_entry_id_seq'::regclass);


--
-- TOC entry 3560 (class 2604 OID 16681)
-- Name: process_targets target_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.process_targets ALTER COLUMN target_id SET DEFAULT nextval('public.process_targets_target_id_seq'::regclass);


--
-- TOC entry 3559 (class 2604 OID 16643)
-- Name: process_types process_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.process_types ALTER COLUMN process_id SET DEFAULT nextval('public.process_types_process_id_seq'::regclass);


--
-- TOC entry 3562 (class 2604 OID 16932)
-- Name: user_access_levels access_level_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_access_levels ALTER COLUMN access_level_id SET DEFAULT nextval('public.access_levels_access_level_id_seq'::regclass);


--
-- TOC entry 3557 (class 2604 OID 16612)
-- Name: user_languages language_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_languages ALTER COLUMN language_id SET DEFAULT nextval('public.languages_language_id_seq'::regclass);


--
-- TOC entry 3563 (class 2604 OID 16941)
-- Name: users worker_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN worker_id SET DEFAULT nextval('public.users_worker_id_seq'::regclass);


--
-- TOC entry 3558 (class 2604 OID 16628)
-- Name: worker_firms firm_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_firms ALTER COLUMN firm_id SET DEFAULT nextval('public.firms_firm_id_seq'::regclass);


--
-- TOC entry 3570 (class 2604 OID 17155)
-- Name: worker_group_names group_name_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_group_names ALTER COLUMN group_name_id SET DEFAULT nextval('public.worker_group_names_group_name_id_seq'::regclass);


--
-- TOC entry 3571 (class 2604 OID 17162)
-- Name: worker_group_numbers group_number_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_group_numbers ALTER COLUMN group_number_id SET DEFAULT nextval('public.worker_group_numbers_group_number_id_seq'::regclass);


--
-- TOC entry 3577 (class 2604 OID 17270)
-- Name: worker_location_list location_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_location_list ALTER COLUMN location_id SET DEFAULT nextval('public.worker_location_list_location_id_seq'::regclass);


--
-- TOC entry 3572 (class 2604 OID 17169)
-- Name: worker_transport_types transport_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_transport_types ALTER COLUMN transport_id SET DEFAULT nextval('public.worker_transport_types_transport_id_seq'::regclass);


--
-- TOC entry 3600 (class 2606 OID 16936)
-- Name: user_access_levels access_levels_access_level_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_access_levels
    ADD CONSTRAINT access_levels_access_level_name_key UNIQUE (access_level_name);


--
-- TOC entry 3602 (class 2606 OID 16934)
-- Name: user_access_levels access_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_access_levels
    ADD CONSTRAINT access_levels_pkey PRIMARY KEY (access_level_id);


--
-- TOC entry 3610 (class 2606 OID 16992)
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (worker_id, attendance_date);


--
-- TOC entry 3582 (class 2606 OID 16523)
-- Name: feedbacks feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedbacks
    ADD CONSTRAINT feedbacks_pkey PRIMARY KEY (feedback_id);


--
-- TOC entry 3588 (class 2606 OID 16632)
-- Name: worker_firms firms_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_firms
    ADD CONSTRAINT firms_name_key UNIQUE (name);


--
-- TOC entry 3590 (class 2606 OID 16630)
-- Name: worker_firms firms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_firms
    ADD CONSTRAINT firms_pkey PRIMARY KEY (firm_id);


--
-- TOC entry 3598 (class 2606 OID 16849)
-- Name: message_group_list groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_group_list
    ADD CONSTRAINT groups_pkey PRIMARY KEY (group_id);


--
-- TOC entry 3584 (class 2606 OID 16616)
-- Name: user_languages languages_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_languages
    ADD CONSTRAINT languages_code_key UNIQUE (code);


--
-- TOC entry 3586 (class 2606 OID 16614)
-- Name: user_languages languages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (language_id);


--
-- TOC entry 3628 (class 2606 OID 17287)
-- Name: message_absence_records message_absence_records_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_absence_records
    ADD CONSTRAINT message_absence_records_pkey PRIMARY KEY (record_id);


--
-- TOC entry 3630 (class 2606 OID 17313)
-- Name: message_attachments message_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_attachments
    ADD CONSTRAINT message_attachments_pkey PRIMARY KEY (attachment_id);


--
-- TOC entry 3622 (class 2606 OID 17215)
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (message_id);


--
-- TOC entry 3624 (class 2606 OID 17255)
-- Name: message_recipients pk_message_recipients; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_recipients
    ADD CONSTRAINT pk_message_recipients PRIMARY KEY (message_id);


--
-- TOC entry 3620 (class 2606 OID 17194)
-- Name: process process_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.process
    ADD CONSTRAINT process_pkey PRIMARY KEY (process_entry_id);


--
-- TOC entry 3596 (class 2606 OID 16683)
-- Name: process_targets process_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.process_targets
    ADD CONSTRAINT process_targets_pkey PRIMARY KEY (target_id);


--
-- TOC entry 3592 (class 2606 OID 16645)
-- Name: process_types process_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.process_types
    ADD CONSTRAINT process_types_pkey PRIMARY KEY (process_id);


--
-- TOC entry 3594 (class 2606 OID 16647)
-- Name: process_types process_types_process_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.process_types
    ADD CONSTRAINT process_types_process_name_key UNIQUE (process_name);


--
-- TOC entry 3612 (class 2606 OID 17078)
-- Name: user_message_groups user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_message_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (user_id, group_id);


--
-- TOC entry 3604 (class 2606 OID 16946)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (worker_id);


--
-- TOC entry 3606 (class 2606 OID 16948)
-- Name: users users_worker_login_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_worker_login_key UNIQUE (worker_login);


--
-- TOC entry 3614 (class 2606 OID 17157)
-- Name: worker_group_names worker_group_names_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_group_names
    ADD CONSTRAINT worker_group_names_pkey1 PRIMARY KEY (group_name_id);


--
-- TOC entry 3616 (class 2606 OID 17164)
-- Name: worker_group_numbers worker_group_numbers_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_group_numbers
    ADD CONSTRAINT worker_group_numbers_pkey1 PRIMARY KEY (group_number_id);


--
-- TOC entry 3626 (class 2606 OID 17272)
-- Name: worker_location_list worker_location_list_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_location_list
    ADD CONSTRAINT worker_location_list_pkey PRIMARY KEY (location_id);


--
-- TOC entry 3618 (class 2606 OID 17171)
-- Name: worker_transport_types worker_transport_types_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_transport_types
    ADD CONSTRAINT worker_transport_types_pkey1 PRIMARY KEY (transport_id);


--
-- TOC entry 3608 (class 2606 OID 16963)
-- Name: worker_info workers_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_info
    ADD CONSTRAINT workers_info_pkey PRIMARY KEY (worker_id);


--
-- TOC entry 3632 (class 2606 OID 16949)
-- Name: users fk_access_level; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_access_level FOREIGN KEY (access_level_id) REFERENCES public.user_access_levels(access_level_id) ON DELETE RESTRICT;


--
-- TOC entry 3633 (class 2606 OID 16969)
-- Name: worker_info fk_firm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_info
    ADD CONSTRAINT fk_firm FOREIGN KEY (firm_id) REFERENCES public.worker_firms(firm_id);


--
-- TOC entry 3634 (class 2606 OID 17172)
-- Name: worker_info fk_group_name; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_info
    ADD CONSTRAINT fk_group_name FOREIGN KEY (group_name_id) REFERENCES public.worker_group_names(group_name_id) ON DELETE SET NULL;


--
-- TOC entry 3635 (class 2606 OID 17177)
-- Name: worker_info fk_group_number; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_info
    ADD CONSTRAINT fk_group_number FOREIGN KEY (group_number_id) REFERENCES public.worker_group_numbers(group_number_id) ON DELETE SET NULL;


--
-- TOC entry 3636 (class 2606 OID 16974)
-- Name: worker_info fk_language; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_info
    ADD CONSTRAINT fk_language FOREIGN KEY (language_id) REFERENCES public.user_languages(language_id);


--
-- TOC entry 3637 (class 2606 OID 17273)
-- Name: worker_info fk_location; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_info
    ADD CONSTRAINT fk_location FOREIGN KEY (location_id) REFERENCES public.worker_location_list(location_id) ON DELETE SET NULL;


--
-- TOC entry 3643 (class 2606 OID 17195)
-- Name: process fk_process_process_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.process
    ADD CONSTRAINT fk_process_process_id FOREIGN KEY (process_id) REFERENCES public.process_types(process_id) ON DELETE CASCADE;


--
-- TOC entry 3631 (class 2606 OID 16684)
-- Name: process_targets fk_process_targets_process_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.process_targets
    ADD CONSTRAINT fk_process_targets_process_id FOREIGN KEY (process_id) REFERENCES public.process_types(process_id) ON DELETE CASCADE;


--
-- TOC entry 3644 (class 2606 OID 17200)
-- Name: process fk_process_worker_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.process
    ADD CONSTRAINT fk_process_worker_id FOREIGN KEY (worker_id) REFERENCES public.worker_info(worker_id) ON DELETE CASCADE;


--
-- TOC entry 3646 (class 2606 OID 17226)
-- Name: message_recipients fk_recipient_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_recipients
    ADD CONSTRAINT fk_recipient_group_id FOREIGN KEY (recipient_group_id) REFERENCES public.message_group_list(group_id) ON DELETE SET NULL;


--
-- TOC entry 3647 (class 2606 OID 17231)
-- Name: message_recipients fk_recipient_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_recipients
    ADD CONSTRAINT fk_recipient_user_id FOREIGN KEY (recipient_user_id) REFERENCES public.worker_info(worker_id) ON DELETE SET NULL;


--
-- TOC entry 3638 (class 2606 OID 17182)
-- Name: worker_info fk_transport; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_info
    ADD CONSTRAINT fk_transport FOREIGN KEY (transport_id) REFERENCES public.worker_transport_types(transport_id) ON DELETE SET NULL;


--
-- TOC entry 3640 (class 2606 OID 16993)
-- Name: attendance fk_worker_attendance; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT fk_worker_attendance FOREIGN KEY (worker_id) REFERENCES public.worker_info(worker_id) ON DELETE CASCADE;


--
-- TOC entry 3639 (class 2606 OID 16964)
-- Name: worker_info fk_worker_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_info
    ADD CONSTRAINT fk_worker_id FOREIGN KEY (worker_id) REFERENCES public.users(worker_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3649 (class 2606 OID 17288)
-- Name: message_absence_records fk_worker_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_absence_records
    ADD CONSTRAINT fk_worker_id FOREIGN KEY (worker_id) REFERENCES public.worker_info(worker_id) ON DELETE CASCADE;


--
-- TOC entry 3650 (class 2606 OID 17314)
-- Name: message_attachments message_attachments_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_attachments
    ADD CONSTRAINT message_attachments_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.messages(message_id);


--
-- TOC entry 3648 (class 2606 OID 17236)
-- Name: message_recipients message_recipients_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_recipients
    ADD CONSTRAINT message_recipients_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.messages(message_id);


--
-- TOC entry 3645 (class 2606 OID 17216)
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.worker_info(worker_id);


--
-- TOC entry 3641 (class 2606 OID 17079)
-- Name: user_message_groups user_groups_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_message_groups
    ADD CONSTRAINT user_groups_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.message_group_list(group_id);


--
-- TOC entry 3642 (class 2606 OID 17084)
-- Name: user_message_groups user_groups_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_message_groups
    ADD CONSTRAINT user_groups_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.worker_info(worker_id);


-- Completed on 2024-07-19 02:03:59 CEST

--
-- PostgreSQL database dump complete
--


--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Postgres.app)
-- Dumped by pg_dump version 16.3

-- Started on 2024-07-22 13:27:12 CEST

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
-- TOC entry 3835 (class 1262 OID 19530)
-- Name: warehouse_db; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE warehouse_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = icu LOCALE = 'en_US.UTF-8' ICU_LOCALE = 'en-US';

ALTER DATABASE warehouse_db OWNER TO postgres;

\connect warehouse_db

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
-- TOC entry 215 (class 1259 OID 19531)
-- Name: user_access_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_access_levels (
    access_level_id integer NOT NULL,
    access_level_name character varying(50) NOT NULL
);


--
-- TOC entry 216 (class 1259 OID 19534)
-- Name: access_levels_access_level_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.access_levels_access_level_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3836 (class 0 OID 0)
-- Dependencies: 216
-- Name: access_levels_access_level_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.access_levels_access_level_id_seq OWNED BY public.user_access_levels.access_level_id;


--
-- TOC entry 217 (class 1259 OID 19535)
-- Name: attendance; Type: TABLE; Schema: public; Owner: -
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


--
-- TOC entry 218 (class 1259 OID 19538)
-- Name: feedbacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feedbacks (
    feedback_id integer NOT NULL,
    feedback_date date NOT NULL,
    worker_id character varying(255),
    feedback_text text NOT NULL
);


--
-- TOC entry 219 (class 1259 OID 19543)
-- Name: feedbacks_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.feedbacks_feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3837 (class 0 OID 0)
-- Dependencies: 219
-- Name: feedbacks_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.feedbacks_feedback_id_seq OWNED BY public.feedbacks.feedback_id;


--
-- TOC entry 220 (class 1259 OID 19544)
-- Name: worker_firms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worker_firms (
    firm_id integer NOT NULL,
    name character varying(255) NOT NULL
);


--
-- TOC entry 221 (class 1259 OID 19547)
-- Name: firms_firm_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.firms_firm_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3838 (class 0 OID 0)
-- Dependencies: 221
-- Name: firms_firm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.firms_firm_id_seq OWNED BY public.worker_firms.firm_id;


--
-- TOC entry 222 (class 1259 OID 19548)
-- Name: message_group_list; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.message_group_list (
    group_id integer NOT NULL,
    group_name character varying(255) NOT NULL
);


--
-- TOC entry 223 (class 1259 OID 19551)
-- Name: groups_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.groups_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3839 (class 0 OID 0)
-- Dependencies: 223
-- Name: groups_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.groups_group_id_seq OWNED BY public.message_group_list.group_id;


--
-- TOC entry 224 (class 1259 OID 19552)
-- Name: user_languages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_languages (
    language_id integer NOT NULL,
    code character varying(3) NOT NULL,
    name character varying(50)
);


--
-- TOC entry 225 (class 1259 OID 19555)
-- Name: languages_language_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.languages_language_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3840 (class 0 OID 0)
-- Dependencies: 225
-- Name: languages_language_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.languages_language_id_seq OWNED BY public.user_languages.language_id;


--
-- TOC entry 226 (class 1259 OID 19556)
-- Name: message_absence_records; Type: TABLE; Schema: public; Owner: -
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


--
-- TOC entry 227 (class 1259 OID 19562)
-- Name: message_absence_records_record_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.message_absence_records_record_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3841 (class 0 OID 0)
-- Dependencies: 227
-- Name: message_absence_records_record_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.message_absence_records_record_id_seq OWNED BY public.message_absence_records.record_id;


--
-- TOC entry 228 (class 1259 OID 19563)
-- Name: message_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.message_attachments (
    attachment_id integer NOT NULL,
    message_id integer,
    file_path text,
    file_type text
);


--
-- TOC entry 229 (class 1259 OID 19568)
-- Name: message_attachments_attachment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.message_attachments_attachment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3842 (class 0 OID 0)
-- Dependencies: 229
-- Name: message_attachments_attachment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.message_attachments_attachment_id_seq OWNED BY public.message_attachments.attachment_id;


--
-- TOC entry 230 (class 1259 OID 19569)
-- Name: message_recipients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.message_recipients (
    message_id integer NOT NULL,
    recipient_group_id integer,
    recipient_user_id integer
);


--
-- TOC entry 231 (class 1259 OID 19572)
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
    message_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    sender_id integer NOT NULL,
    has_attachments boolean DEFAULT false,
    title character varying(255) NOT NULL,
    message_content text
);


--
-- TOC entry 232 (class 1259 OID 19579)
-- Name: messages_message_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.messages_message_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3843 (class 0 OID 0)
-- Dependencies: 232
-- Name: messages_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.messages_message_id_seq OWNED BY public.messages.message_id;


--
-- TOC entry 233 (class 1259 OID 19580)
-- Name: process; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.process (
    process_entry_id integer NOT NULL,
    date date NOT NULL,
    worker_id integer NOT NULL,
    scanned_items integer NOT NULL,
    time_spent numeric(10,2) NOT NULL,
    process_id integer
);


--
-- TOC entry 234 (class 1259 OID 19583)
-- Name: process_process_entry_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.process_process_entry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3844 (class 0 OID 0)
-- Dependencies: 234
-- Name: process_process_entry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.process_process_entry_id_seq OWNED BY public.process.process_entry_id;


--
-- TOC entry 235 (class 1259 OID 19584)
-- Name: process_targets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.process_targets (
    target_id integer NOT NULL,
    process_id integer NOT NULL,
    target_date date NOT NULL,
    target_items_per_hour integer NOT NULL
);


--
-- TOC entry 236 (class 1259 OID 19587)
-- Name: process_targets_target_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.process_targets_target_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3845 (class 0 OID 0)
-- Dependencies: 236
-- Name: process_targets_target_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.process_targets_target_id_seq OWNED BY public.process_targets.target_id;


--
-- TOC entry 237 (class 1259 OID 19588)
-- Name: process_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.process_types (
    process_id integer NOT NULL,
    process_name character varying(20) NOT NULL
);


--
-- TOC entry 238 (class 1259 OID 19591)
-- Name: process_types_process_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.process_types_process_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3846 (class 0 OID 0)
-- Dependencies: 238
-- Name: process_types_process_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.process_types_process_id_seq OWNED BY public.process_types.process_id;


--
-- TOC entry 239 (class 1259 OID 19592)
-- Name: user_message_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_message_groups (
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


--
-- TOC entry 240 (class 1259 OID 19595)
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    worker_id integer NOT NULL,
    worker_login character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    access_level_id integer DEFAULT 1 NOT NULL,
    is_logged_in boolean DEFAULT false NOT NULL
);


--
-- TOC entry 241 (class 1259 OID 19602)
-- Name: users_worker_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_worker_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3847 (class 0 OID 0)
-- Dependencies: 241
-- Name: users_worker_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_worker_id_seq OWNED BY public.users.worker_id;


--
-- TOC entry 242 (class 1259 OID 19603)
-- Name: worker_group_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worker_group_names (
    group_name_id integer NOT NULL,
    name character varying(50) NOT NULL
);


--
-- TOC entry 243 (class 1259 OID 19606)
-- Name: worker_group_names_group_name_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.worker_group_names_group_name_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3848 (class 0 OID 0)
-- Dependencies: 243
-- Name: worker_group_names_group_name_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.worker_group_names_group_name_id_seq OWNED BY public.worker_group_names.group_name_id;


--
-- TOC entry 244 (class 1259 OID 19607)
-- Name: worker_group_numbers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worker_group_numbers (
    group_number_id integer NOT NULL,
    number character varying(50) NOT NULL
);


--
-- TOC entry 245 (class 1259 OID 19610)
-- Name: worker_group_numbers_group_number_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.worker_group_numbers_group_number_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3849 (class 0 OID 0)
-- Dependencies: 245
-- Name: worker_group_numbers_group_number_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.worker_group_numbers_group_number_id_seq OWNED BY public.worker_group_numbers.group_number_id;


--
-- TOC entry 246 (class 1259 OID 19611)
-- Name: worker_info; Type: TABLE; Schema: public; Owner: -
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


--
-- TOC entry 247 (class 1259 OID 19618)
-- Name: worker_location_list; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worker_location_list (
    location_id integer NOT NULL,
    location_name character varying(255) NOT NULL
);


--
-- TOC entry 248 (class 1259 OID 19621)
-- Name: worker_location_list_location_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.worker_location_list_location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3850 (class 0 OID 0)
-- Dependencies: 248
-- Name: worker_location_list_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.worker_location_list_location_id_seq OWNED BY public.worker_location_list.location_id;


--
-- TOC entry 249 (class 1259 OID 19622)
-- Name: worker_transport_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worker_transport_types (
    transport_id integer NOT NULL,
    name character varying(50) NOT NULL
);


--
-- TOC entry 250 (class 1259 OID 19625)
-- Name: worker_transport_types_transport_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.worker_transport_types_transport_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3851 (class 0 OID 0)
-- Dependencies: 250
-- Name: worker_transport_types_transport_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.worker_transport_types_transport_id_seq OWNED BY public.worker_transport_types.transport_id;


--
-- TOC entry 3557 (class 2604 OID 19626)
-- Name: feedbacks feedback_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedbacks ALTER COLUMN feedback_id SET DEFAULT nextval('public.feedbacks_feedback_id_seq'::regclass);


--
-- TOC entry 3561 (class 2604 OID 19627)
-- Name: message_absence_records record_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_absence_records ALTER COLUMN record_id SET DEFAULT nextval('public.message_absence_records_record_id_seq'::regclass);


--
-- TOC entry 3563 (class 2604 OID 19628)
-- Name: message_attachments attachment_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_attachments ALTER COLUMN attachment_id SET DEFAULT nextval('public.message_attachments_attachment_id_seq'::regclass);


--
-- TOC entry 3559 (class 2604 OID 19629)
-- Name: message_group_list group_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_group_list ALTER COLUMN group_id SET DEFAULT nextval('public.groups_group_id_seq'::regclass);


--
-- TOC entry 3564 (class 2604 OID 19630)
-- Name: messages message_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages ALTER COLUMN message_id SET DEFAULT nextval('public.messages_message_id_seq'::regclass);


--
-- TOC entry 3567 (class 2604 OID 19631)
-- Name: process process_entry_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.process ALTER COLUMN process_entry_id SET DEFAULT nextval('public.process_process_entry_id_seq'::regclass);


--
-- TOC entry 3568 (class 2604 OID 19632)
-- Name: process_targets target_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.process_targets ALTER COLUMN target_id SET DEFAULT nextval('public.process_targets_target_id_seq'::regclass);


--
-- TOC entry 3569 (class 2604 OID 19633)
-- Name: process_types process_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.process_types ALTER COLUMN process_id SET DEFAULT nextval('public.process_types_process_id_seq'::regclass);


--
-- TOC entry 3556 (class 2604 OID 19634)
-- Name: user_access_levels access_level_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_access_levels ALTER COLUMN access_level_id SET DEFAULT nextval('public.access_levels_access_level_id_seq'::regclass);


--
-- TOC entry 3560 (class 2604 OID 19635)
-- Name: user_languages language_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_languages ALTER COLUMN language_id SET DEFAULT nextval('public.languages_language_id_seq'::regclass);


--
-- TOC entry 3570 (class 2604 OID 19636)
-- Name: users worker_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN worker_id SET DEFAULT nextval('public.users_worker_id_seq'::regclass);


--
-- TOC entry 3558 (class 2604 OID 19637)
-- Name: worker_firms firm_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_firms ALTER COLUMN firm_id SET DEFAULT nextval('public.firms_firm_id_seq'::regclass);


--
-- TOC entry 3573 (class 2604 OID 19638)
-- Name: worker_group_names group_name_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_group_names ALTER COLUMN group_name_id SET DEFAULT nextval('public.worker_group_names_group_name_id_seq'::regclass);


--
-- TOC entry 3574 (class 2604 OID 19639)
-- Name: worker_group_numbers group_number_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_group_numbers ALTER COLUMN group_number_id SET DEFAULT nextval('public.worker_group_numbers_group_number_id_seq'::regclass);


--
-- TOC entry 3579 (class 2604 OID 19640)
-- Name: worker_location_list location_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_location_list ALTER COLUMN location_id SET DEFAULT nextval('public.worker_location_list_location_id_seq'::regclass);


--
-- TOC entry 3580 (class 2604 OID 19641)
-- Name: worker_transport_types transport_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_transport_types ALTER COLUMN transport_id SET DEFAULT nextval('public.worker_transport_types_transport_id_seq'::regclass);


--
-- TOC entry 3796 (class 0 OID 19535)
-- Dependencies: 217
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.attendance (worker_id, attendance_date, day_type, scheduled_start_time, scheduled_end_time, scheduled_work_hours, actual_work_hours, absence_reason, break_time) FROM stdin;
15	2024-06-28	P	06:00:00	14:00:00	8.00	8.00	\N	00:27:00
15	2024-06-29	P	06:00:00	14:00:00	8.00	8.00	\N	00:30:00
15	2024-06-30	P	06:00:00	14:00:00	8.00	8.00	\N	00:30:00
15	2024-07-01	P	06:00:00	14:00:00	8.00	8.00	\N	00:28:00
15	2024-07-02	P	06:00:00	14:00:00	8.00	8.00	\N	00:28:00
15	2024-07-03	W	\N	\N	\N	\N	\N	00:00:00
15	2024-07-04	ŚW	\N	\N	\N	\N	\N	00:00:00
16	2024-06-28	P	06:00:00	14:00:00	8.00	8.00	\N	00:28:00
16	2024-06-29	P	06:00:00	14:00:00	8.00	8.00	\N	00:25:00
16	2024-06-30	P	06:00:00	14:00:00	8.00	8.00	\N	00:28:00
16	2024-07-01	P	06:00:00	14:00:00	8.00	8.00	\N	00:31:00
16	2024-07-02	W	\N	\N	\N	\N	\N	00:00:00
16	2024-07-03	W	\N	\N	\N	\N	\N	00:00:00
16	2024-07-04	ŚW	\N	\N	\N	\N	\N	00:00:00
17	2024-06-28	P	14:00:00	22:00:00	8.00	8.00	\N	00:29:00
17	2024-06-29	P	14:00:00	22:00:00	8.00	8.00	\N	00:29:00
17	2024-06-30	P	14:00:00	22:00:00	8.00	8.00	\N	00:29:00
17	2024-07-01	P	14:00:00	22:00:00	8.00	8.00	\N	00:31:00
17	2024-07-02	P	14:00:00	22:00:00	8.00	8.00	\N	00:29:00
17	2024-07-03	W	\N	\N	\N	\N	\N	00:00:00
17	2024-07-04	ŚW	\N	\N	\N	\N	\N	00:00:00
18	2024-06-28	P	14:00:00	22:00:00	8.00	8.00	\N	00:31:00
18	2024-06-29	P	14:00:00	22:00:00	8.00	8.00	\N	00:30:00
18	2024-06-30	P	14:00:00	22:00:00	8.00	8.00	\N	00:29:00
18	2024-07-01	P	14:00:00	22:00:00	8.00	8.00	\N	00:31:00
18	2024-07-02	P	14:00:00	22:00:00	8.00	8.00	\N	00:30:00
18	2024-07-03	W	\N	\N	\N	\N	\N	00:00:00
18	2024-07-04	ŚW	\N	\N	\N	\N	\N	00:00:00
\.


--
-- TOC entry 3797 (class 0 OID 19538)
-- Dependencies: 218
-- Data for Name: feedbacks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.feedbacks (feedback_id, feedback_date, worker_id, feedback_text) FROM stdin;
26	2024-07-12	LOGIN1	Skarga text Lorem lorem lorem lorem lorem
27	2024-07-18	LOGIN1	Skarga text2 Lorem lorem lorem lorem lorem
28	2024-07-18	anonymous	Skarga text3 Lorem lorem lorem lorem lorem
29	2024-07-18	LOGIN1	Skarga text4 Lorem lorem lorem lorem lorem
\.


--
-- TOC entry 3805 (class 0 OID 19556)
-- Dependencies: 226
-- Data for Name: message_absence_records; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.message_absence_records (record_id, worker_id, start_date, end_date, message, sent_at, file_url) FROM stdin;
\.


--
-- TOC entry 3807 (class 0 OID 19563)
-- Dependencies: 228
-- Data for Name: message_attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.message_attachments (attachment_id, message_id, file_path, file_type) FROM stdin;
\.


--
-- TOC entry 3801 (class 0 OID 19548)
-- Dependencies: 222
-- Data for Name: message_group_list; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.message_group_list (group_id, group_name) FROM stdin;
7	all
8	managment
\.


--
-- TOC entry 3809 (class 0 OID 19569)
-- Dependencies: 230
-- Data for Name: message_recipients; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.message_recipients (message_id, recipient_group_id, recipient_user_id) FROM stdin;
108	7	\N
109	7	\N
110	\N	15
\.


--
-- TOC entry 3810 (class 0 OID 19572)
-- Dependencies: 231
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.messages (message_id, created_at, sender_id, has_attachments, title, message_content) FROM stdin;
108	2024-07-22 13:19:59.754819	3	f	Inventory Update	<p style="margin-bottom: 0px; font-style: normal; font-variant-caps: normal; font-stretch: normal; font-size: 14px; line-height: normal; font-family: &quot;.SF NS&quot;; font-size-adjust: none; font-kerning: auto; font-variant-alternates: normal; font-variant-ligatures: normal; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-position: normal; font-variant-emoji: normal; font-feature-settings: normal; font-optical-sizing: auto; font-variation-settings: normal; color: rgb(14, 14, 14);">We are pleased to inform you that our inventory management is improving, and we have successfully completed several key tasks. Your hard work and dedication are greatly appreciated. Please continue to report any issues or suggestions to help us maintain efficiency.</p><p style="margin-bottom: 0px; font-style: normal; font-variant-caps: normal; font-stretch: normal; font-size: 14px; line-height: normal; font-family: &quot;.SF NS&quot;; font-size-adjust: none; font-kerning: auto; font-variant-alternates: normal; font-variant-ligatures: normal; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-position: normal; font-variant-emoji: normal; font-feature-settings: normal; font-optical-sizing: auto; font-variation-settings: normal; color: rgb(14, 14, 14); min-height: 17px;"><br></p><p style="margin-bottom: 0px; font-style: normal; font-variant-caps: normal; font-stretch: normal; font-size: 14px; line-height: normal; font-family: &quot;.SF NS&quot;; font-size-adjust: none; font-kerning: auto; font-variant-alternates: normal; font-variant-ligatures: normal; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-position: normal; font-variant-emoji: normal; font-feature-settings: normal; font-optical-sizing: auto; font-variation-settings: normal; color: rgb(14, 14, 14);">Thank you for your excellent work!</p>
109	2024-07-22 13:20:28.548343	3	f	Request for Feedback and Suggestions	<p style="margin-bottom: 0px; font-style: normal; font-variant-caps: normal; font-stretch: normal; font-size: 14px; line-height: normal; font-family: &quot;.SF NS&quot;; font-size-adjust: none; font-kerning: auto; font-variant-alternates: normal; font-variant-ligatures: normal; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-position: normal; font-variant-emoji: normal; font-feature-settings: normal; font-optical-sizing: auto; font-variation-settings: normal; color: rgb(14, 14, 14);">Hi, team!</p>\r\n<p style="margin-bottom: 0px; font-style: normal; font-variant-caps: normal; font-stretch: normal; font-size: 14px; line-height: normal; font-family: &quot;.SF NS&quot;; font-size-adjust: none; font-kerning: auto; font-variant-alternates: normal; font-variant-ligatures: normal; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-position: normal; font-variant-emoji: normal; font-feature-settings: normal; font-optical-sizing: auto; font-variation-settings: normal; color: rgb(14, 14, 14); min-height: 17px;"><br></p>\r\n<p style="margin-bottom: 0px; font-style: normal; font-variant-caps: normal; font-stretch: normal; font-size: 14px; line-height: normal; font-family: &quot;.SF NS&quot;; font-size-adjust: none; font-kerning: auto; font-variant-alternates: normal; font-variant-ligatures: normal; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-position: normal; font-variant-emoji: normal; font-feature-settings: normal; font-optical-sizing: auto; font-variation-settings: normal; color: rgb(14, 14, 14);">We are always striving to improve our warehouse operations and value your ideas and suggestions. Please take a moment to share your thoughts on how we can enhance our processes and work environment. Your feedback is crucial for our continuous improvement.</p>\r\n<p style="margin-bottom: 0px; font-style: normal; font-variant-caps: normal; font-stretch: normal; font-size: 14px; line-height: normal; font-family: &quot;.SF NS&quot;; font-size-adjust: none; font-kerning: auto; font-variant-alternates: normal; font-variant-ligatures: normal; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-position: normal; font-variant-emoji: normal; font-feature-settings: normal; font-optical-sizing: auto; font-variation-settings: normal; color: rgb(14, 14, 14); min-height: 17px;"><br></p>\r\n<p style="margin-bottom: 0px; font-style: normal; font-variant-caps: normal; font-stretch: normal; font-size: 14px; line-height: normal; font-family: &quot;.SF NS&quot;; font-size-adjust: none; font-kerning: auto; font-variant-alternates: normal; font-variant-ligatures: normal; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-position: normal; font-variant-emoji: normal; font-feature-settings: normal; font-optical-sizing: auto; font-variation-settings: normal; color: rgb(14, 14, 14);">Thank you for your participation and contribution!</p><div><br></div>
110	2024-07-22 13:21:32.774433	3	f	Appreciation for Your Excellent Work	<p style="margin-bottom: 0px; font-style: normal; font-variant-caps: normal; font-stretch: normal; font-size: 14px; line-height: normal; font-family: &quot;.SF NS&quot;; font-size-adjust: none; font-kerning: auto; font-variant-alternates: normal; font-variant-ligatures: normal; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-position: normal; font-variant-emoji: normal; font-feature-settings: normal; font-optical-sizing: auto; font-variation-settings: normal; color: rgb(14, 14, 14);">Hi [Employee’s Name],</p>\r\n<p style="margin-bottom: 0px; font-style: normal; font-variant-caps: normal; font-stretch: normal; font-size: 14px; line-height: normal; font-family: &quot;.SF NS&quot;; font-size-adjust: none; font-kerning: auto; font-variant-alternates: normal; font-variant-ligatures: normal; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-position: normal; font-variant-emoji: normal; font-feature-settings: normal; font-optical-sizing: auto; font-variation-settings: normal; color: rgb(14, 14, 14); min-height: 17px;"><br></p>\r\n<p style="margin-bottom: 0px; font-style: normal; font-variant-caps: normal; font-stretch: normal; font-size: 14px; line-height: normal; font-family: &quot;.SF NS&quot;; font-size-adjust: none; font-kerning: auto; font-variant-alternates: normal; font-variant-ligatures: normal; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-position: normal; font-variant-emoji: normal; font-feature-settings: normal; font-optical-sizing: auto; font-variation-settings: normal; color: rgb(14, 14, 14);">I wanted to take a moment to personally thank you for the outstanding work you have been doing in the warehouse. Your attention to detail and dedication to maintaining our inventory have not gone unnoticed. You consistently go above and beyond, and your efforts are greatly appreciated.</p>
\.


--
-- TOC entry 3812 (class 0 OID 19580)
-- Dependencies: 233
-- Data for Name: process; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.process (process_entry_id, date, worker_id, scanned_items, time_spent, process_id) FROM stdin;
111	2024-06-28	15	201	7.56	3
112	2024-06-29	15	195	7.00	3
113	2024-06-30	15	303	10.84	3
114	2024-07-01	15	49	1.70	3
115	2024-07-02	15	314	10.62	3
116	2024-06-28	15	45	1.51	1
117	2024-06-29	15	35	1.08	1
118	2024-06-30	15	356	10.87	1
119	2024-07-01	15	168	4.99	1
120	2024-07-02	15	252	7.19	1
121	2024-06-28	15	54	1.49	2
122	2024-06-29	15	30	0.82	2
123	2024-06-30	15	390	10.54	2
124	2024-07-01	15	65	1.71	2
125	2024-07-02	15	107	2.80	2
126	2024-06-28	15	49	1.28	4
127	2024-06-29	15	238	6.14	4
128	2024-06-30	15	68	1.73	4
129	2024-07-01	15	420	10.57	4
130	2024-07-02	15	49	1.23	4
131	2024-06-28	15	147	3.15	3
132	2024-06-29	15	145	2.96	3
133	2024-06-30	15	143	2.78	3
134	2024-07-01	15	141	2.60	3
135	2024-07-02	15	139	2.41	3
136	2024-06-28	15	137	2.23	1
137	2024-06-29	15	135	2.04	1
138	2024-06-30	15	133	1.86	1
139	2024-07-01	15	131	1.67	1
140	2024-07-02	15	129	1.49	1
141	2024-06-28	15	127	1.31	2
142	2024-06-29	15	125	1.12	2
143	2024-06-30	15	123	0.94	2
144	2024-07-01	15	121	2.04	2
145	2024-07-02	15	119	1.86	2
146	2024-06-28	15	117	1.67	4
147	2024-06-29	15	115	1.49	4
148	2024-06-30	15	113	0.02	4
149	2024-07-01	15	111	-0.17	4
150	2024-07-02	15	109	2.04	4
151	2024-06-28	15	107	1.86	3
152	2024-06-29	15	104	2.04	3
153	2024-06-30	15	102	1.86	3
154	2024-07-01	15	100	1.67	3
155	2024-07-02	15	98	1.49	3
\.


--
-- TOC entry 3814 (class 0 OID 19584)
-- Dependencies: 235
-- Data for Name: process_targets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.process_targets (target_id, process_id, target_date, target_items_per_hour) FROM stdin;
1	1	2024-03-01	110
2	2	2024-03-01	120
3	3	2024-03-01	75
4	4	2024-03-01	90
5	1	2024-02-01	100
6	2	2024-02-01	110
7	3	2024-02-01	80
8	4	2024-02-01	100
9	1	2024-04-01	150
10	2	2024-04-01	140
11	3	2024-04-01	85
12	4	2024-04-01	95
\.


--
-- TOC entry 3816 (class 0 OID 19588)
-- Dependencies: 237
-- Data for Name: process_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.process_types (process_id, process_name) FROM stdin;
1	PROCES1
2	PROCES2
3	PROCES3
4	PROCES4
\.


--
-- TOC entry 3794 (class 0 OID 19531)
-- Dependencies: 215
-- Data for Name: user_access_levels; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_access_levels (access_level_id, access_level_name) FROM stdin;
1	user
2	admin
3	superadmin
4	koordynator
\.


--
-- TOC entry 3803 (class 0 OID 19552)
-- Dependencies: 224
-- Data for Name: user_languages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_languages (language_id, code, name) FROM stdin;
1	eng	English
3	rus	Russian
2	pln	Polish
4	ukr	Ukrainian
\.


--
-- TOC entry 3818 (class 0 OID 19592)
-- Dependencies: 239
-- Data for Name: user_message_groups; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_message_groups (user_id, group_id) FROM stdin;
1	7
3	8
16	8
15	8
15	7
\.


--
-- TOC entry 3819 (class 0 OID 19595)
-- Dependencies: 240
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (worker_id, worker_login, password, access_level_id, is_logged_in) FROM stdin;
1	1	1	1	f
2	2	2	2	f
3	3	3	3	f
4	4	4	1	f
15	LOGIN1	1	1	f
16	LOGIN2	2	1	f
17	LOGIN3	3	1	f
18	LOGIN4	4	1	f
\.


--
-- TOC entry 3799 (class 0 OID 19544)
-- Dependencies: 220
-- Data for Name: worker_firms; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.worker_firms (firm_id, name) FROM stdin;
1	FirmaMain
2	Firma1
3	Firma2
4	Firma3
5	Firma4
6	Firma5
\.


--
-- TOC entry 3821 (class 0 OID 19603)
-- Dependencies: 242
-- Data for Name: worker_group_names; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.worker_group_names (group_name_id, name) FROM stdin;
1	GROUP_NAME1
2	GROUP_NAME2
3	GROUP_NAME3
\.


--
-- TOC entry 3823 (class 0 OID 19607)
-- Dependencies: 244
-- Data for Name: worker_group_numbers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.worker_group_numbers (group_number_id, number) FROM stdin;
1	1
2	2
3	3
4	4
5	5
6	6
7	7
8	8
9	9
10	10
11	11
12	12
13	13
14	14
15	15
16	A
17	Indywidualny
\.


--
-- TOC entry 3825 (class 0 OID 19611)
-- Dependencies: 246
-- Data for Name: worker_info; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.worker_info (worker_id, fullname, is_active, last_messages_check, language_id, firm_id, transport_id, group_name_id, group_number_id, location_id) FROM stdin;
1	1	t	2024-04-13 02:51:19.690969	2	1	\N	\N	\N	\N
3	3	t	2024-04-25 20:17:49.431083	2	1	\N	\N	\N	\N
17	Adam Sandler	t	2024-07-12 10:12:57.772873	1	3	\N	3	12	\N
18	Hideo Kojima	t	2024-07-12 10:12:57.808625	1	5	\N	1	14	\N
16	Keanu Reeves	t	2024-07-22 13:08:24.113236	1	2	\N	1	12	\N
15	Jason Statham	t	2024-07-22 13:21:54.775406	1	2	\N	2	1	\N
\.


--
-- TOC entry 3826 (class 0 OID 19618)
-- Dependencies: 247
-- Data for Name: worker_location_list; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.worker_location_list (location_id, location_name) FROM stdin;
1	Location1
2	Location2
3	Location3
\.


--
-- TOC entry 3828 (class 0 OID 19622)
-- Dependencies: 249
-- Data for Name: worker_transport_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.worker_transport_types (transport_id, name) FROM stdin;
\.


--
-- TOC entry 3852 (class 0 OID 0)
-- Dependencies: 216
-- Name: access_levels_access_level_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.access_levels_access_level_id_seq', 4, true);


--
-- TOC entry 3853 (class 0 OID 0)
-- Dependencies: 219
-- Name: feedbacks_feedback_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.feedbacks_feedback_id_seq', 30, true);


--
-- TOC entry 3854 (class 0 OID 0)
-- Dependencies: 221
-- Name: firms_firm_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.firms_firm_id_seq', 10, true);


--
-- TOC entry 3855 (class 0 OID 0)
-- Dependencies: 223
-- Name: groups_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.groups_group_id_seq', 8, true);


--
-- TOC entry 3856 (class 0 OID 0)
-- Dependencies: 225
-- Name: languages_language_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.languages_language_id_seq', 4, true);


--
-- TOC entry 3857 (class 0 OID 0)
-- Dependencies: 227
-- Name: message_absence_records_record_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.message_absence_records_record_id_seq', 1, true);


--
-- TOC entry 3858 (class 0 OID 0)
-- Dependencies: 229
-- Name: message_attachments_attachment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.message_attachments_attachment_id_seq', 72, true);


--
-- TOC entry 3859 (class 0 OID 0)
-- Dependencies: 232
-- Name: messages_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.messages_message_id_seq', 110, true);


--
-- TOC entry 3860 (class 0 OID 0)
-- Dependencies: 234
-- Name: process_process_entry_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.process_process_entry_id_seq', 155, true);


--
-- TOC entry 3861 (class 0 OID 0)
-- Dependencies: 236
-- Name: process_targets_target_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.process_targets_target_id_seq', 12, true);


--
-- TOC entry 3862 (class 0 OID 0)
-- Dependencies: 238
-- Name: process_types_process_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.process_types_process_id_seq', 4, true);


--
-- TOC entry 3863 (class 0 OID 0)
-- Dependencies: 241
-- Name: users_worker_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_worker_id_seq', 18, true);


--
-- TOC entry 3864 (class 0 OID 0)
-- Dependencies: 243
-- Name: worker_group_names_group_name_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.worker_group_names_group_name_id_seq', 6, true);


--
-- TOC entry 3865 (class 0 OID 0)
-- Dependencies: 245
-- Name: worker_group_numbers_group_number_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.worker_group_numbers_group_number_id_seq', 17, true);


--
-- TOC entry 3866 (class 0 OID 0)
-- Dependencies: 248
-- Name: worker_location_list_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.worker_location_list_location_id_seq', 3, true);


--
-- TOC entry 3867 (class 0 OID 0)
-- Dependencies: 250
-- Name: worker_transport_types_transport_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.worker_transport_types_transport_id_seq', 1, false);


--
-- TOC entry 3582 (class 2606 OID 19643)
-- Name: user_access_levels access_levels_access_level_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_access_levels
    ADD CONSTRAINT access_levels_access_level_name_key UNIQUE (access_level_name);


--
-- TOC entry 3584 (class 2606 OID 19645)
-- Name: user_access_levels access_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_access_levels
    ADD CONSTRAINT access_levels_pkey PRIMARY KEY (access_level_id);


--
-- TOC entry 3586 (class 2606 OID 19647)
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (worker_id, attendance_date);


--
-- TOC entry 3588 (class 2606 OID 19649)
-- Name: feedbacks feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedbacks
    ADD CONSTRAINT feedbacks_pkey PRIMARY KEY (feedback_id);


--
-- TOC entry 3590 (class 2606 OID 19651)
-- Name: worker_firms firms_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_firms
    ADD CONSTRAINT firms_name_key UNIQUE (name);


--
-- TOC entry 3592 (class 2606 OID 19653)
-- Name: worker_firms firms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_firms
    ADD CONSTRAINT firms_pkey PRIMARY KEY (firm_id);


--
-- TOC entry 3594 (class 2606 OID 19655)
-- Name: message_group_list groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_group_list
    ADD CONSTRAINT groups_pkey PRIMARY KEY (group_id);


--
-- TOC entry 3596 (class 2606 OID 19657)
-- Name: user_languages languages_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_languages
    ADD CONSTRAINT languages_code_key UNIQUE (code);


--
-- TOC entry 3598 (class 2606 OID 19659)
-- Name: user_languages languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (language_id);


--
-- TOC entry 3600 (class 2606 OID 19661)
-- Name: message_absence_records message_absence_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_absence_records
    ADD CONSTRAINT message_absence_records_pkey PRIMARY KEY (record_id);


--
-- TOC entry 3602 (class 2606 OID 19663)
-- Name: message_attachments message_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_attachments
    ADD CONSTRAINT message_attachments_pkey PRIMARY KEY (attachment_id);


--
-- TOC entry 3606 (class 2606 OID 19665)
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (message_id);


--
-- TOC entry 3604 (class 2606 OID 19667)
-- Name: message_recipients pk_message_recipients; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_recipients
    ADD CONSTRAINT pk_message_recipients PRIMARY KEY (message_id);


--
-- TOC entry 3608 (class 2606 OID 19669)
-- Name: process process_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.process
    ADD CONSTRAINT process_pkey PRIMARY KEY (process_entry_id);


--
-- TOC entry 3610 (class 2606 OID 19671)
-- Name: process_targets process_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.process_targets
    ADD CONSTRAINT process_targets_pkey PRIMARY KEY (target_id);


--
-- TOC entry 3612 (class 2606 OID 19673)
-- Name: process_types process_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.process_types
    ADD CONSTRAINT process_types_pkey PRIMARY KEY (process_id);


--
-- TOC entry 3614 (class 2606 OID 19675)
-- Name: process_types process_types_process_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.process_types
    ADD CONSTRAINT process_types_process_name_key UNIQUE (process_name);


--
-- TOC entry 3616 (class 2606 OID 19677)
-- Name: user_message_groups user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_message_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (user_id, group_id);


--
-- TOC entry 3618 (class 2606 OID 19679)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (worker_id);


--
-- TOC entry 3620 (class 2606 OID 19681)
-- Name: users users_worker_login_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_worker_login_key UNIQUE (worker_login);


--
-- TOC entry 3622 (class 2606 OID 19683)
-- Name: worker_group_names worker_group_names_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_group_names
    ADD CONSTRAINT worker_group_names_pkey1 PRIMARY KEY (group_name_id);


--
-- TOC entry 3624 (class 2606 OID 19685)
-- Name: worker_group_numbers worker_group_numbers_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_group_numbers
    ADD CONSTRAINT worker_group_numbers_pkey1 PRIMARY KEY (group_number_id);


--
-- TOC entry 3628 (class 2606 OID 19687)
-- Name: worker_location_list worker_location_list_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_location_list
    ADD CONSTRAINT worker_location_list_pkey PRIMARY KEY (location_id);


--
-- TOC entry 3630 (class 2606 OID 19689)
-- Name: worker_transport_types worker_transport_types_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_transport_types
    ADD CONSTRAINT worker_transport_types_pkey1 PRIMARY KEY (transport_id);


--
-- TOC entry 3626 (class 2606 OID 19691)
-- Name: worker_info workers_info_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_info
    ADD CONSTRAINT workers_info_pkey PRIMARY KEY (worker_id);


--
-- TOC entry 3643 (class 2606 OID 19692)
-- Name: users fk_access_level; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_access_level FOREIGN KEY (access_level_id) REFERENCES public.user_access_levels(access_level_id) ON DELETE RESTRICT;


--
-- TOC entry 3644 (class 2606 OID 19697)
-- Name: worker_info fk_firm; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_info
    ADD CONSTRAINT fk_firm FOREIGN KEY (firm_id) REFERENCES public.worker_firms(firm_id);


--
-- TOC entry 3645 (class 2606 OID 19702)
-- Name: worker_info fk_group_name; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_info
    ADD CONSTRAINT fk_group_name FOREIGN KEY (group_name_id) REFERENCES public.worker_group_names(group_name_id) ON DELETE SET NULL;


--
-- TOC entry 3646 (class 2606 OID 19707)
-- Name: worker_info fk_group_number; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_info
    ADD CONSTRAINT fk_group_number FOREIGN KEY (group_number_id) REFERENCES public.worker_group_numbers(group_number_id) ON DELETE SET NULL;


--
-- TOC entry 3647 (class 2606 OID 19712)
-- Name: worker_info fk_language; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_info
    ADD CONSTRAINT fk_language FOREIGN KEY (language_id) REFERENCES public.user_languages(language_id);


--
-- TOC entry 3648 (class 2606 OID 19717)
-- Name: worker_info fk_location; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_info
    ADD CONSTRAINT fk_location FOREIGN KEY (location_id) REFERENCES public.worker_location_list(location_id) ON DELETE SET NULL;


--
-- TOC entry 3638 (class 2606 OID 19722)
-- Name: process fk_process_process_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.process
    ADD CONSTRAINT fk_process_process_id FOREIGN KEY (process_id) REFERENCES public.process_types(process_id) ON DELETE CASCADE;


--
-- TOC entry 3640 (class 2606 OID 19727)
-- Name: process_targets fk_process_targets_process_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.process_targets
    ADD CONSTRAINT fk_process_targets_process_id FOREIGN KEY (process_id) REFERENCES public.process_types(process_id) ON DELETE CASCADE;


--
-- TOC entry 3639 (class 2606 OID 19732)
-- Name: process fk_process_worker_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.process
    ADD CONSTRAINT fk_process_worker_id FOREIGN KEY (worker_id) REFERENCES public.worker_info(worker_id) ON DELETE CASCADE;


--
-- TOC entry 3634 (class 2606 OID 19737)
-- Name: message_recipients fk_recipient_group_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_recipients
    ADD CONSTRAINT fk_recipient_group_id FOREIGN KEY (recipient_group_id) REFERENCES public.message_group_list(group_id) ON DELETE SET NULL;


--
-- TOC entry 3635 (class 2606 OID 19742)
-- Name: message_recipients fk_recipient_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_recipients
    ADD CONSTRAINT fk_recipient_user_id FOREIGN KEY (recipient_user_id) REFERENCES public.worker_info(worker_id) ON DELETE SET NULL;


--
-- TOC entry 3649 (class 2606 OID 19747)
-- Name: worker_info fk_transport; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_info
    ADD CONSTRAINT fk_transport FOREIGN KEY (transport_id) REFERENCES public.worker_transport_types(transport_id) ON DELETE SET NULL;


--
-- TOC entry 3631 (class 2606 OID 19752)
-- Name: attendance fk_worker_attendance; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT fk_worker_attendance FOREIGN KEY (worker_id) REFERENCES public.worker_info(worker_id) ON DELETE CASCADE;


--
-- TOC entry 3650 (class 2606 OID 19757)
-- Name: worker_info fk_worker_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_info
    ADD CONSTRAINT fk_worker_id FOREIGN KEY (worker_id) REFERENCES public.users(worker_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3632 (class 2606 OID 19762)
-- Name: message_absence_records fk_worker_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_absence_records
    ADD CONSTRAINT fk_worker_id FOREIGN KEY (worker_id) REFERENCES public.worker_info(worker_id) ON DELETE CASCADE;


--
-- TOC entry 3633 (class 2606 OID 19767)
-- Name: message_attachments message_attachments_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_attachments
    ADD CONSTRAINT message_attachments_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.messages(message_id);


--
-- TOC entry 3636 (class 2606 OID 19772)
-- Name: message_recipients message_recipients_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_recipients
    ADD CONSTRAINT message_recipients_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.messages(message_id);


--
-- TOC entry 3637 (class 2606 OID 19777)
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.worker_info(worker_id);


--
-- TOC entry 3641 (class 2606 OID 19782)
-- Name: user_message_groups user_groups_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_message_groups
    ADD CONSTRAINT user_groups_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.message_group_list(group_id);


--
-- TOC entry 3642 (class 2606 OID 19787)
-- Name: user_message_groups user_groups_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_message_groups
    ADD CONSTRAINT user_groups_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.worker_info(worker_id);


-- Completed on 2024-07-22 13:27:12 CEST

--
-- PostgreSQL database dump complete
--


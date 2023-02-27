--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1 (Debian 15.1-1.pgdg110+1)
-- Dumped by pg_dump version 15.2

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
-- Name: alarm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alarm (
    id bigint NOT NULL,
    ongoing boolean,
    resolved_at timestamp(0) without time zone,
    triggered_by_check_id bigint,
    resolved_by_check_id bigint,
    monitor_id bigint,
    organization_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: alarm_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alarm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alarm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alarm_id_seq OWNED BY public.alarm.id;


--
-- Name: assertion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assertion (
    id bigint NOT NULL,
    source integer DEFAULT 1,
    property character varying(255),
    comparison integer DEFAULT 1,
    value character varying(255),
    monitor_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: assertion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assertion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assertion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assertion_id_seq OWNED BY public.assertion.id;


--
-- Name: check; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."check" (
    id bigint NOT NULL,
    status_code integer,
    duration integer DEFAULT 0,
    success boolean DEFAULT false NOT NULL,
    region_id bigint,
    monitor_id bigint,
    organization_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: check_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.check_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: check_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.check_id_seq OWNED BY public."check".id;


--
-- Name: daily_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.daily_report (
    id bigint NOT NULL,
    successful_checks integer DEFAULT 0,
    error_checks integer DEFAULT 0,
    downtime integer DEFAULT 0,
    date date,
    monitor_id bigint,
    organization_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: daily_report_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.daily_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: daily_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.daily_report_id_seq OWNED BY public.daily_report.id;


--
-- Name: error_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.error_log (
    id bigint NOT NULL,
    text text,
    type integer,
    screenshot_url character varying(255),
    check_id bigint,
    monitor_id bigint,
    assertion_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: error_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.error_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: error_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.error_log_id_seq OWNED BY public.error_log.id;


--
-- Name: feature; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feature (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    type integer DEFAULT 1,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: feature_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.feature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feature_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.feature_id_seq OWNED BY public.feature.id;


--
-- Name: guest_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guest_user (
    id bigint NOT NULL,
    email character varying(255) NOT NULL,
    code character varying(255) NOT NULL,
    expires_at timestamp(0) without time zone NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: guest_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.guest_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: guest_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.guest_user_id_seq OWNED BY public.guest_user.id;


--
-- Name: invitation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invitation (
    id bigint NOT NULL,
    email character varying(255) NOT NULL,
    code character varying(255) NOT NULL,
    expires_at timestamp(0) without time zone NOT NULL,
    notification_count integer DEFAULT 1,
    invited_by_user_id bigint,
    role_id bigint,
    organization_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: invitation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invitation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invitation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invitation_id_seq OWNED BY public.invitation.id;


--
-- Name: monitor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitor (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    url character varying(255) NOT NULL,
    method integer DEFAULT 1,
    "interval" integer DEFAULT 300,
    timeout integer DEFAULT 5,
    type integer DEFAULT 1,
    body text,
    body_format integer DEFAULT 1,
    headers jsonb DEFAULT '{}'::jsonb,
    username text,
    password text,
    "on" boolean DEFAULT true,
    muted boolean DEFAULT false,
    status integer DEFAULT 1,
    check_ssl boolean DEFAULT false,
    follow_redirects boolean DEFAULT false,
    next_check_at timestamp(0) without time zone,
    last_checked_at timestamp(0) without time zone,
    last_failed_at timestamp(0) without time zone,
    user_id bigint,
    monitor_group_id bigint,
    prev_id bigint,
    organization_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: monitor_alarm_policy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitor_alarm_policy (
    id bigint NOT NULL,
    reason character varying(255),
    threshold integer DEFAULT 0,
    monitor_id bigint,
    organization_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: monitor_alarm_policy_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monitor_alarm_policy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monitor_alarm_policy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monitor_alarm_policy_id_seq OWNED BY public.monitor_alarm_policy.id;


--
-- Name: monitor_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitor_group (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    organization_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: monitor_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monitor_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monitor_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monitor_group_id_seq OWNED BY public.monitor_group.id;


--
-- Name: monitor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monitor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monitor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monitor_id_seq OWNED BY public.monitor.id;


--
-- Name: monitor_integration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitor_integration (
    id bigint NOT NULL,
    name character varying(255),
    type integer,
    config jsonb,
    organization_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: monitor_integration_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monitor_integration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monitor_integration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monitor_integration_id_seq OWNED BY public.monitor_integration.id;


--
-- Name: monitor_notification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitor_notification (
    id bigint NOT NULL,
    type integer,
    successful boolean DEFAULT true NOT NULL,
    alarm_id bigint,
    monitor_id bigint,
    user_contact_id bigint,
    organization_id bigint,
    integration_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: monitor_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monitor_notification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monitor_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monitor_notification_id_seq OWNED BY public.monitor_notification.id;


--
-- Name: monitor_notification_policy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitor_notification_policy (
    id bigint NOT NULL,
    user_id bigint,
    monitor_id bigint,
    organization_id bigint,
    integration_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: monitor_notification_policy_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monitor_notification_policy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monitor_notification_policy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monitor_notification_policy_id_seq OWNED BY public.monitor_notification_policy.id;


--
-- Name: monitor_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitor_region (
    id bigint NOT NULL,
    down boolean DEFAULT false,
    last_checked_at timestamp(0) without time zone,
    monitor_id bigint,
    region_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: monitor_region_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monitor_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monitor_region_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monitor_region_id_seq OWNED BY public.monitor_region.id;


--
-- Name: monitor_status_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitor_status_change (
    id bigint NOT NULL,
    status integer DEFAULT 1,
    changed_at timestamp(0) without time zone,
    monitor_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: monitor_status_change_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monitor_status_change_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monitor_status_change_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monitor_status_change_id_seq OWNED BY public.monitor_status_change.id;


--
-- Name: organization; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: organization_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_id_seq OWNED BY public.organization.id;


--
-- Name: organization_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_user (
    id bigint NOT NULL,
    status integer DEFAULT 1,
    role_id bigint,
    user_id bigint,
    organization_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: organization_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_user_id_seq OWNED BY public.organization_user.id;


--
-- Name: plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan (
    id bigint NOT NULL,
    price double precision NOT NULL,
    type integer DEFAULT 1,
    external_id character varying(255),
    product_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: plan_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.plan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.plan_id_seq OWNED BY public.plan.id;


--
-- Name: product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    external_id character varying(255),
    tier integer DEFAULT 1,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: product_feature; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_feature (
    id bigint NOT NULL,
    count integer DEFAULT 1,
    product_id bigint,
    feature_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: product_feature_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_feature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_feature_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_feature_id_seq OWNED BY public.product_feature.id;


--
-- Name: product_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;


--
-- Name: receipt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.receipt (
    id bigint NOT NULL,
    price double precision NOT NULL,
    currency character varying(255) DEFAULT 'usd'::character varying,
    external_id character varying(255),
    external_customer_id character varying(255),
    url character varying(255),
    status integer,
    paid boolean DEFAULT false,
    paid_at timestamp(0) without time zone,
    "from" date,
    "to" date,
    is_trial boolean DEFAULT false,
    plan_id bigint,
    product_id bigint,
    subscription_id bigint,
    organization_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: receipt_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.receipt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: receipt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.receipt_id_seq OWNED BY public.receipt.id;


--
-- Name: region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.region (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    key character varying(255) NOT NULL,
    ip_address character varying(255),
    "default" boolean DEFAULT false,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: region_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: region_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.region_id_seq OWNED BY public.region.id;


--
-- Name: role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    type integer DEFAULT 1,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: role_claim; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_claim (
    id bigint NOT NULL,
    claim character varying(255) NOT NULL,
    role_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: role_claim_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.role_claim_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role_claim_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.role_claim_id_seq OWNED BY public.role_claim.id;


--
-- Name: role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.role_id_seq OWNED BY public.role.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: subscription; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscription (
    id bigint NOT NULL,
    status integer,
    starts_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    canceled_at timestamp(0) without time zone,
    is_trial boolean DEFAULT false,
    external_id character varying(255),
    external_customer_id character varying(255),
    plan_id bigint,
    product_id bigint,
    organization_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscription_id_seq OWNED BY public.subscription.id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user" (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    picture_url character varying(255),
    password character varying(255),
    payment_customer_id character varying(255),
    provider_uid character varying(255),
    provider integer DEFAULT 1,
    last_login_at timestamp(0) without time zone DEFAULT now(),
    role_id bigint,
    organization_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: user_contact; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_contact (
    id bigint NOT NULL,
    email character varying(255),
    number character varying(255),
    mode integer,
    device_id character varying(255),
    verification_code character varying(255),
    verification_code_expires_at timestamp(0) without time zone,
    verified boolean DEFAULT false NOT NULL,
    subscribed boolean DEFAULT true NOT NULL,
    bounce_count integer DEFAULT 0,
    user_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: user_contact_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_contact_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_contact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_contact_id_seq OWNED BY public.user_contact.id;


--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;


--
-- Name: alarm id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alarm ALTER COLUMN id SET DEFAULT nextval('public.alarm_id_seq'::regclass);


--
-- Name: assertion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assertion ALTER COLUMN id SET DEFAULT nextval('public.assertion_id_seq'::regclass);


--
-- Name: check id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."check" ALTER COLUMN id SET DEFAULT nextval('public.check_id_seq'::regclass);


--
-- Name: daily_report id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_report ALTER COLUMN id SET DEFAULT nextval('public.daily_report_id_seq'::regclass);


--
-- Name: error_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_log ALTER COLUMN id SET DEFAULT nextval('public.error_log_id_seq'::regclass);


--
-- Name: feature id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature ALTER COLUMN id SET DEFAULT nextval('public.feature_id_seq'::regclass);


--
-- Name: guest_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_user ALTER COLUMN id SET DEFAULT nextval('public.guest_user_id_seq'::regclass);


--
-- Name: invitation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitation ALTER COLUMN id SET DEFAULT nextval('public.invitation_id_seq'::regclass);


--
-- Name: monitor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor ALTER COLUMN id SET DEFAULT nextval('public.monitor_id_seq'::regclass);


--
-- Name: monitor_alarm_policy id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_alarm_policy ALTER COLUMN id SET DEFAULT nextval('public.monitor_alarm_policy_id_seq'::regclass);


--
-- Name: monitor_group id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_group ALTER COLUMN id SET DEFAULT nextval('public.monitor_group_id_seq'::regclass);


--
-- Name: monitor_integration id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_integration ALTER COLUMN id SET DEFAULT nextval('public.monitor_integration_id_seq'::regclass);


--
-- Name: monitor_notification id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_notification ALTER COLUMN id SET DEFAULT nextval('public.monitor_notification_id_seq'::regclass);


--
-- Name: monitor_notification_policy id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_notification_policy ALTER COLUMN id SET DEFAULT nextval('public.monitor_notification_policy_id_seq'::regclass);


--
-- Name: monitor_region id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_region ALTER COLUMN id SET DEFAULT nextval('public.monitor_region_id_seq'::regclass);


--
-- Name: monitor_status_change id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_status_change ALTER COLUMN id SET DEFAULT nextval('public.monitor_status_change_id_seq'::regclass);


--
-- Name: organization id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization ALTER COLUMN id SET DEFAULT nextval('public.organization_id_seq'::regclass);


--
-- Name: organization_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_user ALTER COLUMN id SET DEFAULT nextval('public.organization_user_id_seq'::regclass);


--
-- Name: plan id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plan ALTER COLUMN id SET DEFAULT nextval('public.plan_id_seq'::regclass);


--
-- Name: product id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);


--
-- Name: product_feature id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_feature ALTER COLUMN id SET DEFAULT nextval('public.product_feature_id_seq'::regclass);


--
-- Name: receipt id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipt ALTER COLUMN id SET DEFAULT nextval('public.receipt_id_seq'::regclass);


--
-- Name: region id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region ALTER COLUMN id SET DEFAULT nextval('public.region_id_seq'::regclass);


--
-- Name: role id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role ALTER COLUMN id SET DEFAULT nextval('public.role_id_seq'::regclass);


--
-- Name: role_claim id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_claim ALTER COLUMN id SET DEFAULT nextval('public.role_claim_id_seq'::regclass);


--
-- Name: subscription id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription ALTER COLUMN id SET DEFAULT nextval('public.subscription_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Name: user_contact id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_contact ALTER COLUMN id SET DEFAULT nextval('public.user_contact_id_seq'::regclass);


--
-- Name: alarm alarm_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alarm
    ADD CONSTRAINT alarm_pkey PRIMARY KEY (id);


--
-- Name: assertion assertion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assertion
    ADD CONSTRAINT assertion_pkey PRIMARY KEY (id);


--
-- Name: check check_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."check"
    ADD CONSTRAINT check_pkey PRIMARY KEY (id);


--
-- Name: daily_report daily_report_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_report
    ADD CONSTRAINT daily_report_pkey PRIMARY KEY (id);


--
-- Name: error_log error_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_log
    ADD CONSTRAINT error_log_pkey PRIMARY KEY (id);


--
-- Name: feature feature_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature
    ADD CONSTRAINT feature_pkey PRIMARY KEY (id);


--
-- Name: guest_user guest_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_user
    ADD CONSTRAINT guest_user_pkey PRIMARY KEY (id);


--
-- Name: invitation invitation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitation
    ADD CONSTRAINT invitation_pkey PRIMARY KEY (id);


--
-- Name: monitor_alarm_policy monitor_alarm_policy_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_alarm_policy
    ADD CONSTRAINT monitor_alarm_policy_pkey PRIMARY KEY (id);


--
-- Name: monitor_group monitor_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_group
    ADD CONSTRAINT monitor_group_pkey PRIMARY KEY (id);


--
-- Name: monitor_integration monitor_integration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_integration
    ADD CONSTRAINT monitor_integration_pkey PRIMARY KEY (id);


--
-- Name: monitor_notification monitor_notification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_notification
    ADD CONSTRAINT monitor_notification_pkey PRIMARY KEY (id);


--
-- Name: monitor_notification_policy monitor_notification_policy_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_notification_policy
    ADD CONSTRAINT monitor_notification_policy_pkey PRIMARY KEY (id);


--
-- Name: monitor monitor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor
    ADD CONSTRAINT monitor_pkey PRIMARY KEY (id);


--
-- Name: monitor_region monitor_region_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_region
    ADD CONSTRAINT monitor_region_pkey PRIMARY KEY (id);


--
-- Name: monitor_status_change monitor_status_change_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_status_change
    ADD CONSTRAINT monitor_status_change_pkey PRIMARY KEY (id);


--
-- Name: monitor monitor_unique_previous_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor
    ADD CONSTRAINT monitor_unique_previous_id UNIQUE (prev_id, organization_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: organization organization_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_pkey PRIMARY KEY (id);


--
-- Name: organization_user organization_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_user
    ADD CONSTRAINT organization_user_pkey PRIMARY KEY (id);


--
-- Name: plan plan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plan
    ADD CONSTRAINT plan_pkey PRIMARY KEY (id);


--
-- Name: product_feature product_feature_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_feature
    ADD CONSTRAINT product_feature_pkey PRIMARY KEY (id);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- Name: receipt receipt_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT receipt_pkey PRIMARY KEY (id);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: role_claim role_claim_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_claim
    ADD CONSTRAINT role_claim_pkey PRIMARY KEY (id);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: subscription subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT subscription_pkey PRIMARY KEY (id);


--
-- Name: user_contact user_contact_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_contact
    ADD CONSTRAINT user_contact_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: alarm_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX alarm_monitor_id_index ON public.alarm USING btree (monitor_id);


--
-- Name: alarm_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX alarm_organization_id_index ON public.alarm USING btree (organization_id);


--
-- Name: alarm_triggered_by_check_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX alarm_triggered_by_check_id_index ON public.alarm USING btree (triggered_by_check_id);


--
-- Name: assertion_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX assertion_monitor_id_index ON public.assertion USING btree (monitor_id);


--
-- Name: assertion_source_value_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assertion_source_value_monitor_id_index ON public.assertion USING btree (source, value, monitor_id);


--
-- Name: check_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX check_monitor_id_index ON public."check" USING btree (monitor_id);


--
-- Name: check_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX check_organization_id_index ON public."check" USING btree (organization_id);


--
-- Name: check_region_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX check_region_id_index ON public."check" USING btree (region_id);


--
-- Name: daily_report_date_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX daily_report_date_monitor_id_index ON public.daily_report USING btree (date, monitor_id);


--
-- Name: daily_report_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX daily_report_monitor_id_index ON public.daily_report USING btree (monitor_id);


--
-- Name: daily_report_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX daily_report_organization_id_index ON public.daily_report USING btree (organization_id);


--
-- Name: error_log_assertion_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX error_log_assertion_id_index ON public.error_log USING btree (assertion_id);


--
-- Name: error_log_check_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX error_log_check_id_index ON public.error_log USING btree (check_id);


--
-- Name: error_log_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX error_log_monitor_id_index ON public.error_log USING btree (monitor_id);


--
-- Name: feature_name_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX feature_name_type_index ON public.feature USING btree (name, type);


--
-- Name: guest_user_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX guest_user_code_index ON public.guest_user USING btree (code);


--
-- Name: guest_user_expires_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX guest_user_expires_at_index ON public.guest_user USING btree (expires_at);


--
-- Name: invitation_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX invitation_code_index ON public.invitation USING btree (code);


--
-- Name: invitation_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invitation_email_index ON public.invitation USING btree (email);


--
-- Name: invitation_email_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX invitation_email_organization_id_index ON public.invitation USING btree (email, organization_id);


--
-- Name: invitation_expires_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invitation_expires_at_index ON public.invitation USING btree (expires_at);


--
-- Name: invitation_invited_by_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invitation_invited_by_user_id_index ON public.invitation USING btree (invited_by_user_id);


--
-- Name: invitation_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invitation_organization_id_index ON public.invitation USING btree (organization_id);


--
-- Name: invitation_role_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invitation_role_id_index ON public.invitation USING btree (role_id);


--
-- Name: monitor_alarm_policy_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_alarm_policy_monitor_id_index ON public.monitor_alarm_policy USING btree (monitor_id);


--
-- Name: monitor_alarm_policy_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_alarm_policy_organization_id_index ON public.monitor_alarm_policy USING btree (organization_id);


--
-- Name: monitor_alarm_policy_reason_monitor_id_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX monitor_alarm_policy_reason_monitor_id_organization_id_index ON public.monitor_alarm_policy USING btree (reason, monitor_id, organization_id);


--
-- Name: monitor_group_name_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX monitor_group_name_organization_id_index ON public.monitor_group USING btree (name, organization_id);


--
-- Name: monitor_group_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_group_organization_id_index ON public.monitor_group USING btree (organization_id);


--
-- Name: monitor_integration_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_integration_organization_id_index ON public.monitor_integration USING btree (organization_id);


--
-- Name: monitor_integration_type_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX monitor_integration_type_organization_id_index ON public.monitor_integration USING btree (type, organization_id);


--
-- Name: monitor_last_checked_at_next_check_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_last_checked_at_next_check_at_index ON public.monitor USING btree (last_checked_at, next_check_at);


--
-- Name: monitor_monitor_group_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_monitor_group_id_index ON public.monitor USING btree (monitor_group_id);


--
-- Name: monitor_next_check_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_next_check_at_index ON public.monitor USING btree (next_check_at);


--
-- Name: monitor_notification_alarm_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_notification_alarm_id_index ON public.monitor_notification USING btree (alarm_id);


--
-- Name: monitor_notification_alarm_id_type_user_contact_id_integration_; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX monitor_notification_alarm_id_type_user_contact_id_integration_ ON public.monitor_notification USING btree (alarm_id, type, user_contact_id, integration_id);


--
-- Name: monitor_notification_integration_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_notification_integration_id_index ON public.monitor_notification USING btree (integration_id);


--
-- Name: monitor_notification_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_notification_monitor_id_index ON public.monitor_notification USING btree (monitor_id);


--
-- Name: monitor_notification_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_notification_organization_id_index ON public.monitor_notification USING btree (organization_id);


--
-- Name: monitor_notification_policy_integration_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_notification_policy_integration_id_index ON public.monitor_notification_policy USING btree (integration_id);


--
-- Name: monitor_notification_policy_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_notification_policy_monitor_id_index ON public.monitor_notification_policy USING btree (monitor_id);


--
-- Name: monitor_notification_policy_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_notification_policy_organization_id_index ON public.monitor_notification_policy USING btree (organization_id);


--
-- Name: monitor_notification_policy_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_notification_policy_user_id_index ON public.monitor_notification_policy USING btree (user_id);


--
-- Name: monitor_notification_policy_user_id_monitor_id_integration_id_o; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX monitor_notification_policy_user_id_monitor_id_integration_id_o ON public.monitor_notification_policy USING btree (user_id, monitor_id, integration_id, organization_id);


--
-- Name: monitor_notification_user_contact_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_notification_user_contact_id_index ON public.monitor_notification USING btree (user_contact_id);


--
-- Name: monitor_on_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_on_index ON public.monitor USING btree ("on");


--
-- Name: monitor_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_organization_id_index ON public.monitor USING btree (organization_id);


--
-- Name: monitor_region_last_checked_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_region_last_checked_at_index ON public.monitor_region USING btree (last_checked_at);


--
-- Name: monitor_region_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_region_monitor_id_index ON public.monitor_region USING btree (monitor_id);


--
-- Name: monitor_region_region_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_region_region_id_index ON public.monitor_region USING btree (region_id);


--
-- Name: monitor_region_region_id_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX monitor_region_region_id_monitor_id_index ON public.monitor_region USING btree (region_id, monitor_id);


--
-- Name: monitor_status_change_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_status_change_monitor_id_index ON public.monitor_status_change USING btree (monitor_id);


--
-- Name: monitor_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_status_index ON public.monitor USING btree (status);


--
-- Name: monitor_url_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX monitor_url_organization_id_index ON public.monitor USING btree (url, organization_id);


--
-- Name: monitor_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_user_id_index ON public.monitor USING btree (user_id);


--
-- Name: organization_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX organization_slug_index ON public.organization USING btree (slug);


--
-- Name: organization_user_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX organization_user_organization_id_index ON public.organization_user USING btree (organization_id);


--
-- Name: organization_user_role_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX organization_user_role_id_index ON public.organization_user USING btree (role_id);


--
-- Name: organization_user_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX organization_user_user_id_index ON public.organization_user USING btree (user_id);


--
-- Name: organization_user_user_id_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX organization_user_user_id_organization_id_index ON public.organization_user USING btree (user_id, organization_id);


--
-- Name: plan_external_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX plan_external_id_index ON public.plan USING btree (external_id);


--
-- Name: plan_price_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX plan_price_type_index ON public.plan USING btree (price, type);


--
-- Name: plan_product_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX plan_product_id_index ON public.plan USING btree (product_id);


--
-- Name: product_external_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX product_external_id_index ON public.product USING btree (external_id);


--
-- Name: product_feature_feature_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX product_feature_feature_id_index ON public.product_feature USING btree (feature_id);


--
-- Name: product_feature_product_id_feature_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX product_feature_product_id_feature_id_index ON public.product_feature USING btree (product_id, feature_id);


--
-- Name: product_feature_product_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX product_feature_product_id_index ON public.product_feature USING btree (product_id);


--
-- Name: product_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX product_name_index ON public.product USING btree (name);


--
-- Name: product_tier_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX product_tier_index ON public.product USING btree (tier);


--
-- Name: receipt_external_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX receipt_external_id_index ON public.receipt USING btree (external_id);


--
-- Name: receipt_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX receipt_organization_id_index ON public.receipt USING btree (organization_id);


--
-- Name: receipt_plan_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX receipt_plan_id_index ON public.receipt USING btree (plan_id);


--
-- Name: receipt_product_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX receipt_product_id_index ON public.receipt USING btree (product_id);


--
-- Name: receipt_subscription_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX receipt_subscription_id_index ON public.receipt USING btree (subscription_id);


--
-- Name: region_key_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX region_key_index ON public.region USING btree (key);


--
-- Name: role_claim_claim_role_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX role_claim_claim_role_id_index ON public.role_claim USING btree (claim, role_id);


--
-- Name: role_claim_role_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX role_claim_role_id_index ON public.role_claim USING btree (role_id);


--
-- Name: role_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX role_type_index ON public.role USING btree (type);


--
-- Name: subscription_expires_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subscription_expires_at_index ON public.subscription USING btree (expires_at);


--
-- Name: subscription_external_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX subscription_external_id_index ON public.subscription USING btree (external_id);


--
-- Name: subscription_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subscription_organization_id_index ON public.subscription USING btree (organization_id);


--
-- Name: subscription_plan_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subscription_plan_id_index ON public.subscription USING btree (plan_id);


--
-- Name: subscription_product_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subscription_product_id_index ON public.subscription USING btree (product_id);


--
-- Name: subscription_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subscription_status_index ON public.subscription USING btree (status);


--
-- Name: uq_monitor_on_alarm; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_monitor_on_alarm ON public.alarm USING btree (monitor_id, ongoing) WHERE (ongoing = true);


--
-- Name: uq_superadmin_on_org_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_superadmin_on_org_user ON public.organization_user USING btree (role_id, user_id) WHERE (role_id = 1);


--
-- Name: user_contact_device_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_contact_device_id_index ON public.user_contact USING btree (device_id);


--
-- Name: user_contact_email_verified_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_contact_email_verified_index ON public.user_contact USING btree (email, verified);


--
-- Name: user_contact_number_verified_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_contact_number_verified_index ON public.user_contact USING btree (number, verified);


--
-- Name: user_contact_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_contact_user_id_index ON public.user_contact USING btree (user_id);


--
-- Name: user_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_email_index ON public."user" USING btree (email);


--
-- Name: user_last_login_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_last_login_at_index ON public."user" USING btree (last_login_at);


--
-- Name: user_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_organization_id_index ON public."user" USING btree (organization_id);


--
-- Name: user_payment_customer_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_payment_customer_id_index ON public."user" USING btree (payment_customer_id);


--
-- Name: user_provider_uid_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_provider_uid_index ON public."user" USING btree (provider_uid);


--
-- Name: user_role_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_role_id_index ON public."user" USING btree (role_id);


--
-- Name: alarm alarm_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alarm
    ADD CONSTRAINT alarm_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitor(id) ON DELETE CASCADE;


--
-- Name: alarm alarm_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alarm
    ADD CONSTRAINT alarm_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- Name: alarm alarm_resolved_by_check_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alarm
    ADD CONSTRAINT alarm_resolved_by_check_id_fkey FOREIGN KEY (resolved_by_check_id) REFERENCES public."check"(id);


--
-- Name: alarm alarm_triggered_by_check_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alarm
    ADD CONSTRAINT alarm_triggered_by_check_id_fkey FOREIGN KEY (triggered_by_check_id) REFERENCES public."check"(id);


--
-- Name: assertion assertion_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assertion
    ADD CONSTRAINT assertion_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitor(id) ON DELETE CASCADE;


--
-- Name: check check_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."check"
    ADD CONSTRAINT check_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitor(id) ON DELETE CASCADE;


--
-- Name: check check_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."check"
    ADD CONSTRAINT check_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- Name: check check_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."check"
    ADD CONSTRAINT check_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.region(id);


--
-- Name: daily_report daily_report_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_report
    ADD CONSTRAINT daily_report_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitor(id) ON DELETE CASCADE;


--
-- Name: daily_report daily_report_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_report
    ADD CONSTRAINT daily_report_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- Name: error_log error_log_assertion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_log
    ADD CONSTRAINT error_log_assertion_id_fkey FOREIGN KEY (assertion_id) REFERENCES public.assertion(id);


--
-- Name: error_log error_log_check_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_log
    ADD CONSTRAINT error_log_check_id_fkey FOREIGN KEY (check_id) REFERENCES public."check"(id) ON DELETE CASCADE;


--
-- Name: error_log error_log_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_log
    ADD CONSTRAINT error_log_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitor(id) ON DELETE CASCADE;


--
-- Name: invitation invitation_invited_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitation
    ADD CONSTRAINT invitation_invited_by_user_id_fkey FOREIGN KEY (invited_by_user_id) REFERENCES public."user"(id);


--
-- Name: invitation invitation_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitation
    ADD CONSTRAINT invitation_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- Name: invitation invitation_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitation
    ADD CONSTRAINT invitation_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.role(id);


--
-- Name: monitor_alarm_policy monitor_alarm_policy_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_alarm_policy
    ADD CONSTRAINT monitor_alarm_policy_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitor(id) ON DELETE CASCADE;


--
-- Name: monitor_alarm_policy monitor_alarm_policy_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_alarm_policy
    ADD CONSTRAINT monitor_alarm_policy_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- Name: monitor_group monitor_group_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_group
    ADD CONSTRAINT monitor_group_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- Name: monitor_integration monitor_integration_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_integration
    ADD CONSTRAINT monitor_integration_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- Name: monitor monitor_monitor_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor
    ADD CONSTRAINT monitor_monitor_group_id_fkey FOREIGN KEY (monitor_group_id) REFERENCES public.monitor_group(id);


--
-- Name: monitor_notification monitor_notification_alarm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_notification
    ADD CONSTRAINT monitor_notification_alarm_id_fkey FOREIGN KEY (alarm_id) REFERENCES public.alarm(id) ON DELETE CASCADE;


--
-- Name: monitor_notification monitor_notification_integration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_notification
    ADD CONSTRAINT monitor_notification_integration_id_fkey FOREIGN KEY (integration_id) REFERENCES public.monitor_integration(id) ON DELETE CASCADE;


--
-- Name: monitor_notification monitor_notification_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_notification
    ADD CONSTRAINT monitor_notification_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitor(id) ON DELETE CASCADE;


--
-- Name: monitor_notification monitor_notification_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_notification
    ADD CONSTRAINT monitor_notification_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- Name: monitor_notification_policy monitor_notification_policy_integration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_notification_policy
    ADD CONSTRAINT monitor_notification_policy_integration_id_fkey FOREIGN KEY (integration_id) REFERENCES public.monitor_integration(id) ON DELETE CASCADE;


--
-- Name: monitor_notification_policy monitor_notification_policy_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_notification_policy
    ADD CONSTRAINT monitor_notification_policy_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitor(id) ON DELETE CASCADE;


--
-- Name: monitor_notification_policy monitor_notification_policy_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_notification_policy
    ADD CONSTRAINT monitor_notification_policy_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- Name: monitor_notification_policy monitor_notification_policy_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_notification_policy
    ADD CONSTRAINT monitor_notification_policy_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: monitor_notification monitor_notification_user_contact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_notification
    ADD CONSTRAINT monitor_notification_user_contact_id_fkey FOREIGN KEY (user_contact_id) REFERENCES public.user_contact(id) ON DELETE CASCADE;


--
-- Name: monitor monitor_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor
    ADD CONSTRAINT monitor_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- Name: monitor monitor_prev_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor
    ADD CONSTRAINT monitor_prev_id_fkey FOREIGN KEY (prev_id) REFERENCES public.monitor(id) ON DELETE CASCADE;


--
-- Name: monitor_region monitor_region_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_region
    ADD CONSTRAINT monitor_region_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitor(id) ON DELETE CASCADE;


--
-- Name: monitor_region monitor_region_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_region
    ADD CONSTRAINT monitor_region_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.region(id) ON DELETE CASCADE;


--
-- Name: monitor_status_change monitor_status_change_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_status_change
    ADD CONSTRAINT monitor_status_change_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitor(id) ON DELETE CASCADE;


--
-- Name: monitor monitor_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor
    ADD CONSTRAINT monitor_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: organization_user organization_user_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_user
    ADD CONSTRAINT organization_user_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- Name: organization_user organization_user_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_user
    ADD CONSTRAINT organization_user_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.role(id);


--
-- Name: organization_user organization_user_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_user
    ADD CONSTRAINT organization_user_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: plan plan_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plan
    ADD CONSTRAINT plan_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;


--
-- Name: product_feature product_feature_feature_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_feature
    ADD CONSTRAINT product_feature_feature_id_fkey FOREIGN KEY (feature_id) REFERENCES public.feature(id) ON DELETE CASCADE;


--
-- Name: product_feature product_feature_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_feature
    ADD CONSTRAINT product_feature_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;


--
-- Name: receipt receipt_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT receipt_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- Name: receipt receipt_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT receipt_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.plan(id);


--
-- Name: receipt receipt_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT receipt_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id);


--
-- Name: receipt receipt_subscription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT receipt_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES public.subscription(id) ON DELETE CASCADE;


--
-- Name: role_claim role_claim_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_claim
    ADD CONSTRAINT role_claim_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.role(id) ON DELETE CASCADE;


--
-- Name: subscription subscription_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT subscription_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- Name: subscription subscription_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT subscription_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.plan(id);


--
-- Name: subscription subscription_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT subscription_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id);


--
-- Name: user_contact user_contact_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_contact
    ADD CONSTRAINT user_contact_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: user user_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- Name: user user_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.role(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO public."schema_migrations" (version) VALUES (20220716213711);
INSERT INTO public."schema_migrations" (version) VALUES (20220716213731);
INSERT INTO public."schema_migrations" (version) VALUES (20220716213853);
INSERT INTO public."schema_migrations" (version) VALUES (20220720200342);
INSERT INTO public."schema_migrations" (version) VALUES (20220720210432);
INSERT INTO public."schema_migrations" (version) VALUES (20220720211432);
INSERT INTO public."schema_migrations" (version) VALUES (20220720212909);
INSERT INTO public."schema_migrations" (version) VALUES (20220720213033);
INSERT INTO public."schema_migrations" (version) VALUES (20220720223753);
INSERT INTO public."schema_migrations" (version) VALUES (20220720224930);
INSERT INTO public."schema_migrations" (version) VALUES (20220720224940);
INSERT INTO public."schema_migrations" (version) VALUES (20220720224942);
INSERT INTO public."schema_migrations" (version) VALUES (20220720225105);
INSERT INTO public."schema_migrations" (version) VALUES (20220720225114);
INSERT INTO public."schema_migrations" (version) VALUES (20220720225122);
INSERT INTO public."schema_migrations" (version) VALUES (20220804153037);
INSERT INTO public."schema_migrations" (version) VALUES (20220804201541);
INSERT INTO public."schema_migrations" (version) VALUES (20220820122318);
INSERT INTO public."schema_migrations" (version) VALUES (20220820142008);
INSERT INTO public."schema_migrations" (version) VALUES (20220820142130);
INSERT INTO public."schema_migrations" (version) VALUES (20220820154516);
INSERT INTO public."schema_migrations" (version) VALUES (20220820154520);
INSERT INTO public."schema_migrations" (version) VALUES (20220820154535);
INSERT INTO public."schema_migrations" (version) VALUES (20220820155528);
INSERT INTO public."schema_migrations" (version) VALUES (20220913212347);
INSERT INTO public."schema_migrations" (version) VALUES (20220916212622);
INSERT INTO public."schema_migrations" (version) VALUES (20220916213008);
INSERT INTO public."schema_migrations" (version) VALUES (20220928051748);

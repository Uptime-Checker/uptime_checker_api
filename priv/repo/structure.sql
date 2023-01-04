--
-- PostgreSQL database dump
--

-- Dumped from database version 14.2 (Debian 14.2-1.pgdg110+1)
-- Dumped by pg_dump version 15.1

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: oban_job_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.oban_job_state AS ENUM (
    'available',
    'scheduled',
    'executing',
    'retryable',
    'completed',
    'discarded',
    'cancelled'
);


--
-- Name: provider_name; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.provider_name AS ENUM (
    'email',
    'google',
    'apple',
    'github'
);


--
-- Name: oban_jobs_notify(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.oban_jobs_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  channel text;
  notice json;
BEGIN
  IF NEW.state = 'available' THEN
    channel = 'public.oban_insert';
    notice = json_build_object('queue', NEW.queue);

    PERFORM pg_notify(channel, notice::text);
  END IF;

  RETURN NULL;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alarms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alarms (
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
-- Name: alarms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alarms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alarms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alarms_id_seq OWNED BY public.alarms.id;


--
-- Name: assertions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assertions (
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
-- Name: assertions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assertions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assertions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assertions_id_seq OWNED BY public.assertions.id;


--
-- Name: checks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checks (
    id bigint NOT NULL,
    success boolean DEFAULT false NOT NULL,
    duration integer DEFAULT 0,
    region_id bigint,
    monitor_id bigint,
    organization_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: checks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checks_id_seq OWNED BY public.checks.id;


--
-- Name: claims; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.claims (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: claims_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.claims_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: claims_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.claims_id_seq OWNED BY public.claims.id;


--
-- Name: daily_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.daily_reports (
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
-- Name: daily_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.daily_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: daily_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.daily_reports_id_seq OWNED BY public.daily_reports.id;


--
-- Name: error_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.error_logs (
    id bigint NOT NULL,
    text text,
    status_code integer,
    type integer,
    screenshot_url character varying(255),
    check_id bigint,
    monitor_id bigint,
    assertion_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: error_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.error_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: error_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.error_logs_id_seq OWNED BY public.error_logs.id;


--
-- Name: features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.features (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    type integer DEFAULT 1,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: features_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.features_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.features_id_seq OWNED BY public.features.id;


--
-- Name: guest_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guest_users (
    id bigint NOT NULL,
    email character varying(255) NOT NULL,
    code character varying(255) NOT NULL,
    expires_at timestamp(0) without time zone NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: guest_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.guest_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: guest_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.guest_users_id_seq OWNED BY public.guest_users.id;


--
-- Name: invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invitations (
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
-- Name: invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invitations_id_seq OWNED BY public.invitations.id;


--
-- Name: monitor_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitor_groups (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    organization_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: monitor_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monitor_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monitor_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monitor_groups_id_seq OWNED BY public.monitor_groups.id;


--
-- Name: monitor_region_junction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitor_region_junction (
    id bigint NOT NULL,
    last_checked_at timestamp(0) without time zone,
    next_check_at timestamp(0) without time zone,
    consequtive_failure integer DEFAULT 0,
    consequtive_recovery integer DEFAULT 0,
    down boolean DEFAULT false,
    monitor_id bigint,
    region_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: monitor_region_junction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monitor_region_junction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monitor_region_junction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monitor_region_junction_id_seq OWNED BY public.monitor_region_junction.id;


--
-- Name: monitor_status_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitor_status_changes (
    id bigint NOT NULL,
    status integer DEFAULT 1,
    changed_at timestamp(0) without time zone,
    monitor_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: monitor_status_changes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monitor_status_changes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monitor_status_changes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monitor_status_changes_id_seq OWNED BY public.monitor_status_changes.id;


--
-- Name: monitor_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitor_tags (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    monitor_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: monitor_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monitor_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monitor_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monitor_tags_id_seq OWNED BY public.monitor_tags.id;


--
-- Name: monitor_user_junction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitor_user_junction (
    id bigint NOT NULL,
    monitor_id bigint,
    user_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: monitor_user_junction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monitor_user_junction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monitor_user_junction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monitor_user_junction_id_seq OWNED BY public.monitor_user_junction.id;


--
-- Name: monitors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitors (
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
    down boolean DEFAULT false,
    check_ssl boolean DEFAULT false,
    follow_redirects boolean DEFAULT false,
    resolve_threshold integer DEFAULT 1,
    error_threshold integer DEFAULT 1,
    region_threshold integer DEFAULT 1,
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
-- Name: monitors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monitors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monitors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monitors_id_seq OWNED BY public.monitors.id;


--
-- Name: nc_evolutions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_evolutions (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    "titleDown" character varying(255),
    description character varying(255),
    batch integer,
    checksum character varying(255),
    status integer,
    created timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: nc_evolutions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nc_evolutions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nc_evolutions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nc_evolutions_id_seq OWNED BY public.nc_evolutions.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    type integer,
    successful boolean DEFAULT true NOT NULL,
    alarm_id bigint,
    monitor_id bigint,
    user_contact_id bigint,
    organization_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: oban_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oban_jobs (
    id bigint NOT NULL,
    state public.oban_job_state DEFAULT 'available'::public.oban_job_state NOT NULL,
    queue text DEFAULT 'default'::text NOT NULL,
    worker text NOT NULL,
    args jsonb DEFAULT '{}'::jsonb NOT NULL,
    errors jsonb[] DEFAULT ARRAY[]::jsonb[] NOT NULL,
    attempt integer DEFAULT 0 NOT NULL,
    max_attempts integer DEFAULT 20 NOT NULL,
    inserted_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    scheduled_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    attempted_at timestamp without time zone,
    completed_at timestamp without time zone,
    attempted_by text[],
    discarded_at timestamp without time zone,
    priority integer DEFAULT 0 NOT NULL,
    tags character varying(255)[] DEFAULT ARRAY[]::character varying[],
    meta jsonb DEFAULT '{}'::jsonb,
    cancelled_at timestamp without time zone,
    CONSTRAINT attempt_range CHECK (((attempt >= 0) AND (attempt <= max_attempts))),
    CONSTRAINT positive_max_attempts CHECK ((max_attempts > 0)),
    CONSTRAINT priority_range CHECK (((priority >= 0) AND (priority <= 3))),
    CONSTRAINT queue_length CHECK (((char_length(queue) > 0) AND (char_length(queue) < 128))),
    CONSTRAINT worker_length CHECK (((char_length(worker) > 0) AND (char_length(worker) < 128)))
);


--
-- Name: TABLE oban_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.oban_jobs IS '11';


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oban_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oban_jobs_id_seq OWNED BY public.oban_jobs.id;


--
-- Name: oban_peers; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.oban_peers (
    name text NOT NULL,
    node text NOT NULL,
    started_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


--
-- Name: organization_user_junction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_user_junction (
    id bigint NOT NULL,
    status integer DEFAULT 1,
    role_id bigint,
    user_id bigint,
    organization_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: organization_user_junction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_user_junction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_user_junction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_user_junction_id_seq OWNED BY public.organization_user_junction.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plans (
    id bigint NOT NULL,
    price double precision NOT NULL,
    type integer DEFAULT 1,
    external_id character varying(255),
    product_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.plans_id_seq OWNED BY public.plans.id;


--
-- Name: product_feature_junction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_feature_junction (
    id bigint NOT NULL,
    count integer DEFAULT 1,
    product_id bigint,
    feature_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: product_feature_junction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_feature_junction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_feature_junction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_feature_junction_id_seq OWNED BY public.product_feature_junction.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    external_id character varying(255),
    tier integer DEFAULT 1,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: receipts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.receipts (
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
-- Name: receipts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.receipts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: receipts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.receipts_id_seq OWNED BY public.receipts.id;


--
-- Name: regions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.regions (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    key character varying(255) NOT NULL,
    ip_address character varying(255),
    "default" boolean DEFAULT false,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: regions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.regions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: regions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.regions_id_seq OWNED BY public.regions.id;


--
-- Name: role_claim_junction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_claim_junction (
    id bigint NOT NULL,
    role_id bigint,
    claim_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: role_claim_junction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.role_claim_junction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role_claim_junction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.role_claim_junction_id_seq OWNED BY public.role_claim_junction.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    type integer DEFAULT 1,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
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
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;


--
-- Name: user_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_contacts (
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
-- Name: user_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_contacts_id_seq OWNED BY public.user_contacts.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    picture_url character varying(255),
    password character varying(255),
    payment_customer_id character varying(255),
    firebase_uid character varying(255),
    provider integer DEFAULT 1,
    last_login_at timestamp(0) without time zone DEFAULT now(),
    role_id bigint,
    organization_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: alarms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alarms ALTER COLUMN id SET DEFAULT nextval('public.alarms_id_seq'::regclass);


--
-- Name: assertions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assertions ALTER COLUMN id SET DEFAULT nextval('public.assertions_id_seq'::regclass);


--
-- Name: checks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checks ALTER COLUMN id SET DEFAULT nextval('public.checks_id_seq'::regclass);


--
-- Name: claims id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claims ALTER COLUMN id SET DEFAULT nextval('public.claims_id_seq'::regclass);


--
-- Name: daily_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_reports ALTER COLUMN id SET DEFAULT nextval('public.daily_reports_id_seq'::regclass);


--
-- Name: error_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_logs ALTER COLUMN id SET DEFAULT nextval('public.error_logs_id_seq'::regclass);


--
-- Name: features id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.features ALTER COLUMN id SET DEFAULT nextval('public.features_id_seq'::regclass);


--
-- Name: guest_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_users ALTER COLUMN id SET DEFAULT nextval('public.guest_users_id_seq'::regclass);


--
-- Name: invitations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations ALTER COLUMN id SET DEFAULT nextval('public.invitations_id_seq'::regclass);


--
-- Name: monitor_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_groups ALTER COLUMN id SET DEFAULT nextval('public.monitor_groups_id_seq'::regclass);


--
-- Name: monitor_region_junction id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_region_junction ALTER COLUMN id SET DEFAULT nextval('public.monitor_region_junction_id_seq'::regclass);


--
-- Name: monitor_status_changes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_status_changes ALTER COLUMN id SET DEFAULT nextval('public.monitor_status_changes_id_seq'::regclass);


--
-- Name: monitor_tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_tags ALTER COLUMN id SET DEFAULT nextval('public.monitor_tags_id_seq'::regclass);


--
-- Name: monitor_user_junction id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_user_junction ALTER COLUMN id SET DEFAULT nextval('public.monitor_user_junction_id_seq'::regclass);


--
-- Name: monitors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitors ALTER COLUMN id SET DEFAULT nextval('public.monitors_id_seq'::regclass);


--
-- Name: nc_evolutions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_evolutions ALTER COLUMN id SET DEFAULT nextval('public.nc_evolutions_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: oban_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_jobs ALTER COLUMN id SET DEFAULT nextval('public.oban_jobs_id_seq'::regclass);


--
-- Name: organization_user_junction id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_user_junction ALTER COLUMN id SET DEFAULT nextval('public.organization_user_junction_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: plans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plans ALTER COLUMN id SET DEFAULT nextval('public.plans_id_seq'::regclass);


--
-- Name: product_feature_junction id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_feature_junction ALTER COLUMN id SET DEFAULT nextval('public.product_feature_junction_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: receipts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipts ALTER COLUMN id SET DEFAULT nextval('public.receipts_id_seq'::regclass);


--
-- Name: regions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions ALTER COLUMN id SET DEFAULT nextval('public.regions_id_seq'::regclass);


--
-- Name: role_claim_junction id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_claim_junction ALTER COLUMN id SET DEFAULT nextval('public.role_claim_junction_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);


--
-- Name: user_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_contacts ALTER COLUMN id SET DEFAULT nextval('public.user_contacts_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: alarms alarms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alarms
    ADD CONSTRAINT alarms_pkey PRIMARY KEY (id);


--
-- Name: assertions assertions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assertions
    ADD CONSTRAINT assertions_pkey PRIMARY KEY (id);


--
-- Name: checks checks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checks
    ADD CONSTRAINT checks_pkey PRIMARY KEY (id);


--
-- Name: claims claims_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claims
    ADD CONSTRAINT claims_pkey PRIMARY KEY (id);


--
-- Name: daily_reports daily_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_reports
    ADD CONSTRAINT daily_reports_pkey PRIMARY KEY (id);


--
-- Name: error_logs error_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_logs
    ADD CONSTRAINT error_logs_pkey PRIMARY KEY (id);


--
-- Name: features features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.features
    ADD CONSTRAINT features_pkey PRIMARY KEY (id);


--
-- Name: guest_users guest_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_users
    ADD CONSTRAINT guest_users_pkey PRIMARY KEY (id);


--
-- Name: invitations invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (id);


--
-- Name: monitor_groups monitor_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_groups
    ADD CONSTRAINT monitor_groups_pkey PRIMARY KEY (id);


--
-- Name: monitor_region_junction monitor_region_junction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_region_junction
    ADD CONSTRAINT monitor_region_junction_pkey PRIMARY KEY (id);


--
-- Name: monitor_status_changes monitor_status_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_status_changes
    ADD CONSTRAINT monitor_status_changes_pkey PRIMARY KEY (id);


--
-- Name: monitor_tags monitor_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_tags
    ADD CONSTRAINT monitor_tags_pkey PRIMARY KEY (id);


--
-- Name: monitor_user_junction monitor_user_junction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_user_junction
    ADD CONSTRAINT monitor_user_junction_pkey PRIMARY KEY (id);


--
-- Name: monitors monitors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitors
    ADD CONSTRAINT monitors_pkey PRIMARY KEY (id);


--
-- Name: monitors monitors_unique_previous_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitors
    ADD CONSTRAINT monitors_unique_previous_id UNIQUE (prev_id, organization_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: nc_evolutions nc_evolutions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_evolutions
    ADD CONSTRAINT nc_evolutions_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: oban_jobs oban_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_jobs
    ADD CONSTRAINT oban_jobs_pkey PRIMARY KEY (id);


--
-- Name: oban_peers oban_peers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_peers
    ADD CONSTRAINT oban_peers_pkey PRIMARY KEY (name);


--
-- Name: organization_user_junction organization_user_junction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_user_junction
    ADD CONSTRAINT organization_user_junction_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: plans plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_pkey PRIMARY KEY (id);


--
-- Name: product_feature_junction product_feature_junction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_feature_junction
    ADD CONSTRAINT product_feature_junction_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: receipts receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipts
    ADD CONSTRAINT receipts_pkey PRIMARY KEY (id);


--
-- Name: regions regions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (id);


--
-- Name: role_claim_junction role_claim_junction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_claim_junction
    ADD CONSTRAINT role_claim_junction_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: user_contacts user_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_contacts
    ADD CONSTRAINT user_contacts_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: alarms_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX alarms_monitor_id_index ON public.alarms USING btree (monitor_id);


--
-- Name: alarms_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX alarms_organization_id_index ON public.alarms USING btree (organization_id);


--
-- Name: alarms_triggered_by_check_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX alarms_triggered_by_check_id_index ON public.alarms USING btree (triggered_by_check_id);


--
-- Name: assertions_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX assertions_monitor_id_index ON public.assertions USING btree (monitor_id);


--
-- Name: assertions_source_value_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assertions_source_value_monitor_id_index ON public.assertions USING btree (source, value, monitor_id);


--
-- Name: checks_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX checks_monitor_id_index ON public.checks USING btree (monitor_id);


--
-- Name: checks_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX checks_organization_id_index ON public.checks USING btree (organization_id);


--
-- Name: checks_region_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX checks_region_id_index ON public.checks USING btree (region_id);


--
-- Name: claims_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX claims_name_index ON public.claims USING btree (name);


--
-- Name: daily_reports_date_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX daily_reports_date_monitor_id_index ON public.daily_reports USING btree (date, monitor_id);


--
-- Name: daily_reports_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX daily_reports_monitor_id_index ON public.daily_reports USING btree (monitor_id);


--
-- Name: daily_reports_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX daily_reports_organization_id_index ON public.daily_reports USING btree (organization_id);


--
-- Name: error_logs_assertion_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX error_logs_assertion_id_index ON public.error_logs USING btree (assertion_id);


--
-- Name: error_logs_check_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX error_logs_check_id_index ON public.error_logs USING btree (check_id);


--
-- Name: error_logs_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX error_logs_monitor_id_index ON public.error_logs USING btree (monitor_id);


--
-- Name: features_name_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX features_name_type_index ON public.features USING btree (name, type);


--
-- Name: guest_users_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX guest_users_code_index ON public.guest_users USING btree (code);


--
-- Name: guest_users_expires_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX guest_users_expires_at_index ON public.guest_users USING btree (expires_at);


--
-- Name: invitations_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX invitations_code_index ON public.invitations USING btree (code);


--
-- Name: invitations_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invitations_email_index ON public.invitations USING btree (email);


--
-- Name: invitations_email_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX invitations_email_organization_id_index ON public.invitations USING btree (email, organization_id);


--
-- Name: invitations_expires_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invitations_expires_at_index ON public.invitations USING btree (expires_at);


--
-- Name: invitations_invited_by_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invitations_invited_by_user_id_index ON public.invitations USING btree (invited_by_user_id);


--
-- Name: invitations_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invitations_organization_id_index ON public.invitations USING btree (organization_id);


--
-- Name: invitations_role_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invitations_role_id_index ON public.invitations USING btree (role_id);


--
-- Name: monitor_groups_name_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX monitor_groups_name_organization_id_index ON public.monitor_groups USING btree (name, organization_id);


--
-- Name: monitor_groups_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_groups_organization_id_index ON public.monitor_groups USING btree (organization_id);


--
-- Name: monitor_region_junction_last_checked_at_next_check_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_region_junction_last_checked_at_next_check_at_index ON public.monitor_region_junction USING btree (last_checked_at, next_check_at);


--
-- Name: monitor_region_junction_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_region_junction_monitor_id_index ON public.monitor_region_junction USING btree (monitor_id);


--
-- Name: monitor_region_junction_next_check_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_region_junction_next_check_at_index ON public.monitor_region_junction USING btree (next_check_at);


--
-- Name: monitor_region_junction_region_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_region_junction_region_id_index ON public.monitor_region_junction USING btree (region_id);


--
-- Name: monitor_region_junction_region_id_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX monitor_region_junction_region_id_monitor_id_index ON public.monitor_region_junction USING btree (region_id, monitor_id);


--
-- Name: monitor_status_changes_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_status_changes_monitor_id_index ON public.monitor_status_changes USING btree (monitor_id);


--
-- Name: monitor_tags_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_tags_monitor_id_index ON public.monitor_tags USING btree (monitor_id);


--
-- Name: monitor_tags_name_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX monitor_tags_name_monitor_id_index ON public.monitor_tags USING btree (name, monitor_id);


--
-- Name: monitor_user_junction_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_user_junction_monitor_id_index ON public.monitor_user_junction USING btree (monitor_id);


--
-- Name: monitor_user_junction_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitor_user_junction_user_id_index ON public.monitor_user_junction USING btree (user_id);


--
-- Name: monitor_user_junction_user_id_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX monitor_user_junction_user_id_monitor_id_index ON public.monitor_user_junction USING btree (user_id, monitor_id);


--
-- Name: monitors_down_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitors_down_index ON public.monitors USING btree (down);


--
-- Name: monitors_monitor_group_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitors_monitor_group_id_index ON public.monitors USING btree (monitor_group_id);


--
-- Name: monitors_on_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitors_on_index ON public.monitors USING btree ("on");


--
-- Name: monitors_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitors_organization_id_index ON public.monitors USING btree (organization_id);


--
-- Name: monitors_url_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX monitors_url_organization_id_index ON public.monitors USING btree (url, organization_id);


--
-- Name: monitors_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monitors_user_id_index ON public.monitors USING btree (user_id);


--
-- Name: notifications_alarm_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notifications_alarm_id_index ON public.notifications USING btree (alarm_id);


--
-- Name: notifications_alarm_id_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX notifications_alarm_id_type_index ON public.notifications USING btree (alarm_id, type);


--
-- Name: notifications_monitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notifications_monitor_id_index ON public.notifications USING btree (monitor_id);


--
-- Name: notifications_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notifications_organization_id_index ON public.notifications USING btree (organization_id);


--
-- Name: notifications_user_contact_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notifications_user_contact_id_index ON public.notifications USING btree (user_contact_id);


--
-- Name: oban_jobs_args_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_args_index ON public.oban_jobs USING gin (args);


--
-- Name: oban_jobs_meta_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_meta_index ON public.oban_jobs USING gin (meta);


--
-- Name: oban_jobs_state_queue_priority_scheduled_at_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_state_queue_priority_scheduled_at_id_index ON public.oban_jobs USING btree (state, queue, priority, scheduled_at, id);


--
-- Name: organization_user_junction_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX organization_user_junction_organization_id_index ON public.organization_user_junction USING btree (organization_id);


--
-- Name: organization_user_junction_role_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX organization_user_junction_role_id_index ON public.organization_user_junction USING btree (role_id);


--
-- Name: organization_user_junction_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX organization_user_junction_user_id_index ON public.organization_user_junction USING btree (user_id);


--
-- Name: organization_user_junction_user_id_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX organization_user_junction_user_id_organization_id_index ON public.organization_user_junction USING btree (user_id, organization_id);


--
-- Name: organizations_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX organizations_slug_index ON public.organizations USING btree (slug);


--
-- Name: plans_external_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX plans_external_id_index ON public.plans USING btree (external_id);


--
-- Name: plans_price_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX plans_price_type_index ON public.plans USING btree (price, type);


--
-- Name: plans_product_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX plans_product_id_index ON public.plans USING btree (product_id);


--
-- Name: product_feature_junction_feature_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX product_feature_junction_feature_id_index ON public.product_feature_junction USING btree (feature_id);


--
-- Name: product_feature_junction_product_id_feature_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX product_feature_junction_product_id_feature_id_index ON public.product_feature_junction USING btree (product_id, feature_id);


--
-- Name: product_feature_junction_product_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX product_feature_junction_product_id_index ON public.product_feature_junction USING btree (product_id);


--
-- Name: products_external_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX products_external_id_index ON public.products USING btree (external_id);


--
-- Name: products_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX products_name_index ON public.products USING btree (name);


--
-- Name: products_tier_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX products_tier_index ON public.products USING btree (tier);


--
-- Name: receipts_external_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX receipts_external_id_index ON public.receipts USING btree (external_id);


--
-- Name: receipts_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX receipts_organization_id_index ON public.receipts USING btree (organization_id);


--
-- Name: receipts_plan_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX receipts_plan_id_index ON public.receipts USING btree (plan_id);


--
-- Name: receipts_product_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX receipts_product_id_index ON public.receipts USING btree (product_id);


--
-- Name: receipts_subscription_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX receipts_subscription_id_index ON public.receipts USING btree (subscription_id);


--
-- Name: regions_key_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX regions_key_index ON public.regions USING btree (key);


--
-- Name: role_claim_junction_claim_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX role_claim_junction_claim_id_index ON public.role_claim_junction USING btree (claim_id);


--
-- Name: role_claim_junction_claim_id_role_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX role_claim_junction_claim_id_role_id_index ON public.role_claim_junction USING btree (claim_id, role_id);


--
-- Name: role_claim_junction_role_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX role_claim_junction_role_id_index ON public.role_claim_junction USING btree (role_id);


--
-- Name: roles_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX roles_type_index ON public.roles USING btree (type);


--
-- Name: subscriptions_expires_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subscriptions_expires_at_index ON public.subscriptions USING btree (expires_at);


--
-- Name: subscriptions_external_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX subscriptions_external_id_index ON public.subscriptions USING btree (external_id);


--
-- Name: subscriptions_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subscriptions_organization_id_index ON public.subscriptions USING btree (organization_id);


--
-- Name: subscriptions_plan_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subscriptions_plan_id_index ON public.subscriptions USING btree (plan_id);


--
-- Name: subscriptions_product_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subscriptions_product_id_index ON public.subscriptions USING btree (product_id);


--
-- Name: subscriptions_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subscriptions_status_index ON public.subscriptions USING btree (status);


--
-- Name: uq_monitor_on_alarm; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_monitor_on_alarm ON public.alarms USING btree (monitor_id, ongoing) WHERE (ongoing = true);


--
-- Name: uq_superadmin_on_org_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_superadmin_on_org_user ON public.organization_user_junction USING btree (role_id, user_id) WHERE (role_id = 1);


--
-- Name: user_contacts_device_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_contacts_device_id_index ON public.user_contacts USING btree (device_id);


--
-- Name: user_contacts_email_verified_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_contacts_email_verified_index ON public.user_contacts USING btree (email, verified);


--
-- Name: user_contacts_number_verified_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_contacts_number_verified_index ON public.user_contacts USING btree (number, verified);


--
-- Name: user_contacts_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_contacts_user_id_index ON public.user_contacts USING btree (user_id);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: users_firebase_uid_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_firebase_uid_index ON public.users USING btree (firebase_uid);


--
-- Name: users_last_login_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_last_login_at_index ON public.users USING btree (last_login_at);


--
-- Name: users_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_organization_id_index ON public.users USING btree (organization_id);


--
-- Name: users_payment_customer_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_payment_customer_id_index ON public.users USING btree (payment_customer_id);


--
-- Name: users_role_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_role_id_index ON public.users USING btree (role_id);


--
-- Name: oban_jobs oban_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER oban_notify AFTER INSERT ON public.oban_jobs FOR EACH ROW EXECUTE FUNCTION public.oban_jobs_notify();


--
-- Name: alarms alarms_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alarms
    ADD CONSTRAINT alarms_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitors(id) ON DELETE CASCADE;


--
-- Name: alarms alarms_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alarms
    ADD CONSTRAINT alarms_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: alarms alarms_resolved_by_check_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alarms
    ADD CONSTRAINT alarms_resolved_by_check_id_fkey FOREIGN KEY (resolved_by_check_id) REFERENCES public.checks(id);


--
-- Name: alarms alarms_triggered_by_check_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alarms
    ADD CONSTRAINT alarms_triggered_by_check_id_fkey FOREIGN KEY (triggered_by_check_id) REFERENCES public.checks(id);


--
-- Name: assertions assertions_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assertions
    ADD CONSTRAINT assertions_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitors(id) ON DELETE CASCADE;


--
-- Name: checks checks_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checks
    ADD CONSTRAINT checks_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitors(id) ON DELETE CASCADE;


--
-- Name: checks checks_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checks
    ADD CONSTRAINT checks_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: checks checks_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checks
    ADD CONSTRAINT checks_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.regions(id);


--
-- Name: daily_reports daily_reports_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_reports
    ADD CONSTRAINT daily_reports_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitors(id) ON DELETE CASCADE;


--
-- Name: daily_reports daily_reports_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_reports
    ADD CONSTRAINT daily_reports_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: error_logs error_logs_assertion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_logs
    ADD CONSTRAINT error_logs_assertion_id_fkey FOREIGN KEY (assertion_id) REFERENCES public.assertions(id);


--
-- Name: error_logs error_logs_check_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_logs
    ADD CONSTRAINT error_logs_check_id_fkey FOREIGN KEY (check_id) REFERENCES public.checks(id) ON DELETE CASCADE;


--
-- Name: error_logs error_logs_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_logs
    ADD CONSTRAINT error_logs_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitors(id) ON DELETE CASCADE;


--
-- Name: invitations invitations_invited_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_invited_by_user_id_fkey FOREIGN KEY (invited_by_user_id) REFERENCES public.users(id);


--
-- Name: invitations invitations_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: invitations invitations_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: monitor_groups monitor_groups_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_groups
    ADD CONSTRAINT monitor_groups_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: monitor_region_junction monitor_region_junction_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_region_junction
    ADD CONSTRAINT monitor_region_junction_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitors(id) ON DELETE CASCADE;


--
-- Name: monitor_region_junction monitor_region_junction_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_region_junction
    ADD CONSTRAINT monitor_region_junction_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.regions(id) ON DELETE CASCADE;


--
-- Name: monitor_status_changes monitor_status_changes_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_status_changes
    ADD CONSTRAINT monitor_status_changes_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitors(id) ON DELETE CASCADE;


--
-- Name: monitor_tags monitor_tags_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_tags
    ADD CONSTRAINT monitor_tags_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitors(id) ON DELETE CASCADE;


--
-- Name: monitor_user_junction monitor_user_junction_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_user_junction
    ADD CONSTRAINT monitor_user_junction_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitors(id) ON DELETE CASCADE;


--
-- Name: monitor_user_junction monitor_user_junction_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitor_user_junction
    ADD CONSTRAINT monitor_user_junction_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: monitors monitors_monitor_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitors
    ADD CONSTRAINT monitors_monitor_group_id_fkey FOREIGN KEY (monitor_group_id) REFERENCES public.monitor_groups(id);


--
-- Name: monitors monitors_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitors
    ADD CONSTRAINT monitors_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: monitors monitors_prev_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitors
    ADD CONSTRAINT monitors_prev_id_fkey FOREIGN KEY (prev_id) REFERENCES public.monitors(id) ON DELETE CASCADE;


--
-- Name: monitors monitors_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitors
    ADD CONSTRAINT monitors_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: notifications notifications_alarm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_alarm_id_fkey FOREIGN KEY (alarm_id) REFERENCES public.alarms(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_monitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_monitor_id_fkey FOREIGN KEY (monitor_id) REFERENCES public.monitors(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_contact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_contact_id_fkey FOREIGN KEY (user_contact_id) REFERENCES public.user_contacts(id) ON DELETE CASCADE;


--
-- Name: organization_user_junction organization_user_junction_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_user_junction
    ADD CONSTRAINT organization_user_junction_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_user_junction organization_user_junction_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_user_junction
    ADD CONSTRAINT organization_user_junction_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: organization_user_junction organization_user_junction_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_user_junction
    ADD CONSTRAINT organization_user_junction_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: plans plans_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_feature_junction product_feature_junction_feature_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_feature_junction
    ADD CONSTRAINT product_feature_junction_feature_id_fkey FOREIGN KEY (feature_id) REFERENCES public.features(id) ON DELETE CASCADE;


--
-- Name: product_feature_junction product_feature_junction_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_feature_junction
    ADD CONSTRAINT product_feature_junction_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: receipts receipts_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipts
    ADD CONSTRAINT receipts_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: receipts receipts_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipts
    ADD CONSTRAINT receipts_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.plans(id);


--
-- Name: receipts receipts_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipts
    ADD CONSTRAINT receipts_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: receipts receipts_subscription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipts
    ADD CONSTRAINT receipts_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES public.subscriptions(id) ON DELETE CASCADE;


--
-- Name: role_claim_junction role_claim_junction_claim_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_claim_junction
    ADD CONSTRAINT role_claim_junction_claim_id_fkey FOREIGN KEY (claim_id) REFERENCES public.claims(id) ON DELETE CASCADE;


--
-- Name: role_claim_junction role_claim_junction_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_claim_junction
    ADD CONSTRAINT role_claim_junction_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.plans(id);


--
-- Name: subscriptions subscriptions_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: user_contacts user_contacts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_contacts
    ADD CONSTRAINT user_contacts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


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
INSERT INTO public."schema_migrations" (version) VALUES (20220720224940);
INSERT INTO public."schema_migrations" (version) VALUES (20220720225105);
INSERT INTO public."schema_migrations" (version) VALUES (20220720225122);
INSERT INTO public."schema_migrations" (version) VALUES (20220725212517);
INSERT INTO public."schema_migrations" (version) VALUES (20220804153037);
INSERT INTO public."schema_migrations" (version) VALUES (20220804201411);
INSERT INTO public."schema_migrations" (version) VALUES (20220804201541);
INSERT INTO public."schema_migrations" (version) VALUES (20220820122318);
INSERT INTO public."schema_migrations" (version) VALUES (20220820142008);
INSERT INTO public."schema_migrations" (version) VALUES (20220820142130);
INSERT INTO public."schema_migrations" (version) VALUES (20220820154516);
INSERT INTO public."schema_migrations" (version) VALUES (20220820154520);
INSERT INTO public."schema_migrations" (version) VALUES (20220820154535);
INSERT INTO public."schema_migrations" (version) VALUES (20220820155528);
INSERT INTO public."schema_migrations" (version) VALUES (20220913212327);
INSERT INTO public."schema_migrations" (version) VALUES (20220913212347);
INSERT INTO public."schema_migrations" (version) VALUES (20220916212622);
INSERT INTO public."schema_migrations" (version) VALUES (20220916213008);
INSERT INTO public."schema_migrations" (version) VALUES (20220928045517);
INSERT INTO public."schema_migrations" (version) VALUES (20220928051748);

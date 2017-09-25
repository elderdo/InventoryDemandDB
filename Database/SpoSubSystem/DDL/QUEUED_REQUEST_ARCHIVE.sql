DROP TABLE C17DEVLPR.QUEUED_REQUEST_ARCHIVE CASCADE CONSTRAINTS;

CREATE TABLE C17DEVLPR.QUEUED_REQUEST_ARCHIVE
(
  PART                  NUMBER                  NOT NULL,
  SOURCE_LOCATION       NUMBER                  NOT NULL,
  DESTINATION_LOCATION  NUMBER                  NOT NULL,
  DGI_LOCATION          NUMBER,
  DGI_PART              NUMBER,
  REQUEST_DATE          DATE,
  DUE_DATE              DATE,
  REQUEST_TYPE          NUMBER                  NOT NULL,
  REQUEST_STATUS        NUMBER                  NOT NULL,
  QUANTITY              NUMBER                  NOT NULL,
  QUEUED_TIMESTAMP      DATE,
  SPO_USER              NUMBER                  NOT NULL,
  EXCEPTION_RULE        NUMBER                  NOT NULL,
  QUEUE_STATUS          NUMBER                  NOT NULL,
  RELEASE_DATE          DATE                    NOT NULL,
  SNAPSHOT_TIMESTAMP    DATE                    DEFAULT NULL
)
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;



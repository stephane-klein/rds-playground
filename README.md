# AWS RDS playground

I use this playground mainly to test things on [AWS RDS](https://en.wikipedia.org/wiki/Amazon_Relational_Database_Service).

In this playground I use my [AWS Free tier](https://aws.amazon.com/rds/pricing/) credits:

> - Amazon RDS usage per month: 750 hours (30 days) on select Single-AZ Instance databases. Usage is aggregated across
>   instance types if using more than one instance. (Available engines: MySQL, MariaDB, PostgreSQL,
>   or SQL Server – SQL Server Express Edition only.)
> - General Purpose SSD (gp2) storage per month: 20 GB
> - Storage for automated database backups per month: 20 GB

## Prerequisites

- direnv
- mise
- docker and docker compose
- PostgreSQL clients:
  - `psql`
  - `pg_dump`
  - `pg_restore`

## My journey in this playground

```sh
$ cp .secret.skel .secret
```

Fill in the `.secret` file with your AWS credentials and the password for the PostgreSQL
database you wish to create.

```sh
$ direnv allow
$ mise install
$ terraform init
```

```sh
$ terraform plan
```

```sh
$ terraform apply -auto-approve
...
Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + mydatabase = (known after apply)
aws_db_instance.mydatabase: Creating...

...

aws_db_instance.mydatabase: Still creating... [7m50s elapsed]
aws_db_instance.mydatabase: Creation complete after 7m58s [id=db-SX3TZZV5WKXXL5V7IKK2OZOVRQ]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

mydatabase = "terraform-20241025151925891300000001.c7uqqy6awsvc.eu-west-3.rds.amazonaws.com:5432"
```

Note: when I launched this command, it ran in 7 minutes, which seemed a very long time to me,
so I was surprised.

Fake data injection into the database and create a role:

```sh
$ ./scripts/inject-seed-in-remote-rds-pg.sh
```

I check that the data has been injected:

```sh
$ psql -U postgres -h $(terraform output -raw mydatabase | cut -d':' -f1) mydatabase
psql (16.3, server 13.15)
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, compression: off)
Type "help" for help.

mydatabase=> select * from users;
 id | username
----+----------
  1 | user1
  2 | user2
  3 | user3
(3 rows)

mydatabase=> \du
                                List of roles
    Role name    |                         Attributes
-----------------+------------------------------------------------------------
 mydummyrole     | Cannot login
 postgres        | Create role, Create DB                                    +

...

```

Remote RDS database dump generation including roles… in `dump/` folder:

```sh
./scripts/pg_dumpall-remote-rds.sh
```

Launch a local PostgreSQL instance, on my workstation:

```
$ docker compose up -d --wait
```

Import dump to local database:

```
$ ./scripts/pg_restore-to-local-postgres.sh
```

I check whether the RDS remote database dump has been restored correctly locally, including the roles:

```
$ ./scripts/enter-in-local-pg.sh
psql (16.3, server 13.15 (Debian 13.15-1.pgdg120+1))
Type "help" for help.

postgres=# \du
                              List of roles
  Role name  |                         Attributes
-------------+------------------------------------------------------------
 mydummyrole | Cannot login
 postgres    | Create role, Create DB                                    +
             | Password valid until infinity
 rdsadmin    | Superuser, Create role, Create DB, Replication, Bypass RLS

postgres=# select * from users;
 id | username
----+----------
  1 | user1
  2 | user2
  3 | user3
(3 rows)

postgres=#
```

I can see that everything has worked well 🙂.

## Teardown

```sh
$ terraform destroy
$ docker compose down
$ sudo rm -rf ./volumes/
```


## Resources

- Terraform [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) documentation
  - [Resource: aws_db_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance)
- [Using pg_dumpall with AWS RDS Postgres](https://www.thatguyfromdelhi.com/2017/03/using-pgdumpall-with-aws-rds-postgres.html)

# Folio on Rancher 2.x/Kubernetes

## License

Copyright (C) 2016-2024 The Open Library Foundation

This software is distributed under the terms of the Apache License, Version 2.0. See the file "[LICENSE](LICENSE)" for more information.

## Introduction

This extensive how-to guide is spread across seven documents and describes how Texas A&M University Libraries Folio infrastructure is configured and deployed. We maintain many of our own artifacts and configurations for Folio deployments including Docker containers for back-end modules, Okapi, and Stripes. There are also community-provided K8s Helm charts that Folio relies on such as Bitnami Kafka, Elasticsearch and MinIO.<br/>

I assume the reader has extensive knowledge in using Rancher, Docker and Kubernetes as well as a basic understanding of how Folio functions. My goal is to be descriptive on how things are done through the Rancher UI, more advanced users can interact directly with the K8s cluster via kubectl.<br/>

## Contents

* [Setup Rancher 2.x/Kubernetes Cluster](rancher_setup.md)
* [Setup Folio on Rancher 2.x/Kubernetes](folio_setup.md)
* [Dump/Restore/Upgrade Folio Notes](Dump_Restore_Upgrade_Notes.md)
* [Cloning a Folio Tenant](Tenant_Clone.md)
* [Crunchy Postgres Pro-Tips](Crunchy_Postgres_Tips.md)
* [Library Data Platform Notes](LDP_Notes.md)
* [Tips for Creating Faster Queries in LDP Databases](LDP_Faster_Queries.pdf)

---
title: "Creating Bibliothekai with Django, Lightning Web Components, and GraphQL"
layout: post
---

## Introduction

## Integrating Lightning Web Components with Django Templates

I already had a perfectly good templated Django application, and for most of my desired functionality, Django templates worked just fine. There were a couple of areas, however, where static HTML was not cutting it. I wanted to add Lightning Web Components to provide better interactivity, but I didn't want to rebuild my whole site. Besides, I was already using Bootstrap styling and did not want to reskin my existing site to use SLDS.

The solution I came up with is certainly not the most ergonomic use case for the LWC framework, but it hits all of my targets: I can embed Lightning Web Components within an existing server-rendered Django template. Here's how it works.

## Building a Wire Adapter

In the Open Source Lightning Web Components framework, unlike on-platform LWC development, it's possible to build [custom wire adapters](https://lwc.dev/guide/wire_adapter). 

## Creating a Data Table

## Adding GraphQL

Bibliothekai uses a fairly complex data model to allow it to track

- volumes, which contain
  - resources, like introductions and essays, which have
    - authors
  - translations, which have
    - supporting resources, like notes and commentaries, which have
      - authors
    - authors
    - source texts, which have
      - authors
  - a publisher
  - a series

When the API (like a fairly simple one built with Django Rest Framework's `ModelViewSet` class) provides an endpoint for each object in the schema, a complex user view like a translations data table must hit many endpoints and synthetically join records to get the information it needs to display. This is just the application for **GraphQL**, which allows the front end to request the structured data it needs regardless of the underlying table structure and receive a single, complete payload in response.

GraphQL support is easily added to Django via the `graphene-django` library.

I wrote a new wire adapter to support GraphQL queries, which are sent via `POST` and may be parameterized.

```lang-javascript
import { getCookie, getApiEndpoint } from './django.js';

class graphQL {
    query;
    variables;
    dataCallback;

    constructor(dataCallback) {
        this.dataCallback = dataCallback;
    }

    connect() {
        this.refresh();
    }

    disconnect() {
    }

    update(config) {
        if (this.query !== config.query || this.variables !== config.variables) {
            this.query = config.query;
            this.variables = config.variables;

            this.refresh();
        }
    }

    async refresh() {
        if (this.query) {
            let endpoint = getApiEndpoint();

            let result = await fetch(`${endpoint}/graphql`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json;charset=utf-8',
                    'X-CSRFToken': getCookie('csrftoken')
                },
                body: JSON.stringify({ query: this.query, variables: this.variables })
            });

            if (result.ok) {
                this.dataCallback({ data: await result.json() });
            } else {
                this.dataCallback({ error: `The API returned an error: ${result.status}.` });
            }
        }
    }
}

export { graphQL };
```

## Building with Docker on Heroku

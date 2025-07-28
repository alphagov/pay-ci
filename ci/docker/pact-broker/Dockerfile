FROM pactfoundation/pact-broker:2.132.0-pactbroker2.116.0@sha256:f57be41844b94b8f5cbf5f76e55c654a1202c71df5daeb0d48edd2e0c797a20d

FROM node:22.17.1-alpine3.21@sha256:f00440c423ce5657e4d2347fa3b9bf5887389f6fcf3daa25cc79ea11a6a00f80 AS base

FROM base AS builder

FROM maven:3.9.7-eclipse-temurin-21-alpine@sha256:8b762a139e07e874e3830521d97bafaf963cce6bda92afe9fb532def5d011404 AS builder

FROM eclipse-temurin:21-jre-alpine@sha256:7b5c88eb4182a92aab3a4b10550061a6e18639bf176e7ebca21f866b19f853c1 AS final

# --- Base ---
FROM node:16-bullseye-slim AS base

ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETVARIANT
RUN printf "I'm building for TARGETPLATFORM=${TARGETPLATFORM}" \
    && printf ", TARGETARCH=${TARGETARCH}" \
    && printf ", TARGETVARIANT=${TARGETVARIANT} \n" \
    && printf "With uname -s : " && uname -s \
    && printf "and  uname -m : " && uname -m


RUN mkdir -p /opt/node_app && chown -R node:node /opt/node_app
RUN apt-get update && apt-get -y install curl

WORKDIR /opt/node_app
COPY ./package*.json ./

# --- dev ---
FROM base AS dev
RUN npm install

ENV NODE_ENV development
ENV PORT 3000
ENV PATH /opt/node_app/node_modules/.bin:$PATH

# copy in our source code last, as it changes the most
COPY --chown=node:node . .
USER node
CMD [ "npm", "run", "debug" ]

# --- test ---
FROM base as test
RUN npm ci

ENV NODE_ENV test
ENV PORT 3000
ENV PATH /opt/node_app/node_modules/.bin:$PATH

COPY --chown=node:node . .
USER node
# TODO: Permission denied when nyc tries to create .nyc_output/ 
CMD ["npm", "run", "test:ci"]

## --- Build ---
FROM dev as build
RUN npm run build

# --- Release ---
FROM build AS release
COPY --from=build /opt/node_app/dist ./dist
RUN npm ci --only=production

ENV PATH /opt/node_app/node_modules/.bin:$PATH
ENV NODE_ENV production
ENV PORT 3000
CMD [ "npm", "run", "start" ]
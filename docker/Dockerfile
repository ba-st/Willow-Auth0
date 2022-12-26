# Stage 1: Load the project
FROM ghcr.io/ba-st/pharo-loader:v10.0.1 as loader

COPY ./source ./source
COPY ./.git/ ./.git/
RUN pharo metacello install gitlocal://./source \
  BaselineOfWillowAuth0 --groups=Demo

# Stage 2: Copy the Pharo image into the base
FROM ghcr.io/ba-st/launchpad:v4

COPY --from=loader /opt/pharo/Pharo.image ./
COPY --from=loader /opt/pharo/Pharo.changes ./
COPY --from=loader /opt/pharo/Pharo*.sources ./
CMD [ "launchpad-start", "willow-auth0-demo" ]

# Demo

If you load the `Development` group of the baseline it will include a simple demo application.

To try the demo you will need an [Auth0](https://auth0.com) account and to configure a new `Regular Web Application`, with the following configuration:
- http://localhost:3000/willow-auth0-demo in **Allowed Callback URLs**
- http://localhost:3000/willow-auth0-demo in **Allowed Logout URLs**
- `HS256` as **JsonWebToken Signature Algorithm** in the Advanced Settings section
- `Implicit` checked in **Grant Types**
- Copy the provided `.env` file to the working directory of your image and complete the environment variables with valid settings for your application (you can copy them from the Settings tab in Auth0)

In an image with the `Development` group loaded:
- Run your image with: `env $(cat .env | xargs) ./pharo-ui`
- Open a playground and execute `WillowAuth0Demo start`
- Now you can go to your browser and open http://localhost:3000/willow-auth0-demo
- If everything is working Ok you will get redirected to the Universal Login page and after a successful login you will land into the demo app showing the info retrieved from your account and a button for logging off.

# Willow Auth0 Documentation

To learn about the project, [install it](how-to/how-to-load-in-pharo.md).

If you load the `Development` group of the baseline it will include a simple
demo application.

To try the demo you will need an [Auth0](https://auth0.com) account and to
configure a new `Regular Web Application`, with:

- `http://localhost:3000/willow-auth0-demo` in **Allowed Callback URLs**
- `http://localhost:3000/willow-auth0-demo` in **Allowed Logout URLs**
- `HS256` as **JsonWebToken Signature Algorithm** in the Advanced Settings section
- `Implicit` checked in **Grant Types**

Then, use the docker container:

```bash
docker run -d -p 3000:3000 \
  -e PUBLIC_URL=http://localhost:3000/willow-auth0-demo \
  -e AUTH0__DOMAIN={tenant.auth0.com} \
  -e AUTH0__CLIENT_ID={clientId} \
  -e AUTH0__CLIENT_SECRET={secret} \
  ghrc.io/ba-st/willow-auth0-demo:release-candidate
```

replacing the environment variables with valid settings for your application
(you can copy them from the Settings tab in Auth0)

Now you can go to your browser and open `http://localhost:3000/willow-auth0-demo`

If everything is working Ok you will get redirected to the Universal Login
page and after a successful login you will land into the demo app showing the
info retrieved from your account and a button for logging off.

---

To use the project as a dependency of your project, take a look at:

- [How to use Willow Auth0 as a dependency](how-to/how-to-use-as-dependency-in-pharo.md)
- [Baseline groups reference](reference/Baseline-groups.md)

pub type Auth {
  Auth(domain: String, client_id: String, callback: String, audience: String)
}

pub fn build_auth_url(state: String, auth: Auth) -> String {
  "https://"
  <> auth.domain
  <> "/authorize?response_type=code&client_id="
  <> auth.client_id
  <> "&redirect_uri="
  <> auth.callback
  <> "&state="
  <> state
  //  <> "&audience="
  //  <> auth.audience
}

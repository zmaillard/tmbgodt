import tmbgodt/web.{type Context}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) {
    let req = wisp.method_override(req)
    use <- wisp.log_request(req)
    use <- wisp.rescue_crashes
    use req <- wisp.handle_head(req)
    //use ctx <- <- web.authenticate(req,ctx)
    
    case wisp.path_segments(req) {
        [] -> home(ctx)
        _ -> wisp.not_found()
    }
}

fn home(_: Context) -> Response {
    wisp.ok()
}

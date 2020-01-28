
# url map

resource "google_compute_url_map" "shopping_site" {
  name            = "next19shop-url-map"
  default_service = google_compute_backend_service.browse_be_svc.self_link

  host_rule {
    hosts        = [var.global.app_host]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.browse_be_svc.self_link

    path_rule {
      paths   = ["/browse/*", ]
      service = google_compute_backend_service.browse_be_svc.self_link
    }

    path_rule {
      paths   = ["/cart/*"]
      service = google_compute_backend_service.cart_be_svc.self_link
    }

    path_rule {
      paths   = ["/checkout/*", ]
      service = google_compute_backend_service.checkout_be_svc.self_link
    }

    path_rule {
      paths   = ["/feeds/*", ]
      service = google_compute_backend_service.feeds_be_svc.self_link
    }
  }
}

# url map standard tier

resource "google_compute_url_map" "standard_tier" {
  name            = "standard-tier-url-map"
  default_service = google_compute_backend_service.browse_tiers_be_svc.self_link
}

# url map premium tier

resource "google_compute_url_map" "premium_tier" {
  name            = "premium-tier-url-map"
  default_service = google_compute_backend_service.browse_tiers_be_svc.self_link
}

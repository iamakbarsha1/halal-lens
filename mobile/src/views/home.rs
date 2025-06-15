use dioxus::prelude::*;
use ui::{Echo, Hero};

#[component]
pub fn Home() -> Element {
    rsx! {
        div {
            "Bismillah"
        }
        // Hero {}
        // Echo {}
    }
}

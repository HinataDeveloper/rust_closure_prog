// Date: Thu Aug 27 2026

// Project: Learning Chapter 13
// Goal: Using closure
// Dependency: Without dependency

// Zed 1.17.2
// Commit: c8e44cfa7bda9b2e22c8d6934d78969352e7f61a
// Version: 1.17.2+stable.349.c8e44cfa7bda9b2e22c8d6934d78969352e7f61a

// rustc 1.100.0-nightly (bff8e12ff 2026-08-26)
// binary: rustc
// commit-hash: bff8e12ff5e6bcd53dfb1dbccdcec80a60a856ed
// commit-date: 2026-08-26
// host: x86_64-unknown-linux-gnu
// release: 1.100.0-nightly
// LLVM version: 23.1.0

// cargo 1.100.0-nightly (e8cb624d5 2026-08-22)
// release: 1.100.0-nightly
// commit-hash: e8cb624d5701824f46a2ec5873cfd59ee3d2f66c
// commit-date: 2026-08-22
// host: x86_64-unknown-linux-gnu
// libgit2: 1.9.6 (sys:0.21.0 vendored)
// libcurl: 8.21.0-DEV (sys:0.4.90+curl-8.21.0 vendored ssl:OpenSSL/3.6.3)
// ssl: OpenSSL 3.6.3 9 Jun 2026
// os: Ubuntu 26.4.0 (resolute) [64-bit]

// Kernel Version: 7.0.0-30-generic
// Firmware Version: 71CN51WW(V1.21)

fn main() {
    println!("\n");

    let store: Inventory = Inventory {
        shirts: vec![ShirtColor::Blue, ShirtColor::Red, ShirtColor::Blue],
    };

    let user_pref1 = Some(ShirtColor::Red);
    let giveaway1 = store.giveaway(user_pref1);
    println!(
        "The user with preference {:?} get {:?}",
        user_pref1, giveaway1
    );

    let user_pref2 = None;
    let giveaway2 = store.giveaway(user_pref2);
    println!(
        "The user with preference {:?} get {:?}",
        user_pref2, giveaway2
    );

    
    println!("\nThe End ...\n");
}

#[derive(Debug, PartialEq, Clone, Copy)]
enum ShirtColor {
    Red,
    Blue,
}

struct Inventory {
    shirts: Vec<ShirtColor>,
}

impl Inventory {
    fn giveaway(&self, user_preference: Option<ShirtColor>) -> ShirtColor {
        user_preference.unwrap_or_else(|| self.most_stocked())
    }

    fn most_stocked(&self) -> ShirtColor {
        let mut num_red = 0;
        let mut num_blue = 0;

        for color in &self.shirts {
            match color {
                ShirtColor::Blue => num_blue += 1,
                ShirtColor::Red => num_red += 1,
            }
        }

        if num_blue > num_red {
            ShirtColor::Blue
        } else {
            ShirtColor::Red
        }
    }
}

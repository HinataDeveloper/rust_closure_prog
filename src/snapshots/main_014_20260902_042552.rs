// Date: Thu Sep 02 2026

// Project: Learning Chapter 13
// Goal: Using closure
// Dependency: Without dependency

// rustc 1.100.0-nightly (17fd5b8a3 2026-08-28)
// binary: rustc
// commit-hash: 17fd5b8a37b6667b6cc137f3cc35f09759768a3b
// commit-date: 2026-08-28
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
// os: Fedora 44.0.0 [64-bit]

// Kernel Version: 7.1.10-200.fc44.x86_64
// Firmware Version: 71CN51WW(V1.21)

fn main() {
    println!("\n");

    let mut rec_arr = [
        Rectangle {
            width: 12,
            height: 22,
        },
        Rectangle {
            width: 35,
            height: 10,
        },
        Rectangle {
            width: 46,
            height: 15,
        },
        Rectangle {
            width: 15,
            height: 44,
        },
        Rectangle {
            width: 13,
            height: 33,
        },
    ];

    rec_arr.sort_by_key(|r| r.width);
    println!("rectangle list is: {:?}", rec_arr);

    println!("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");

    rec_arr.sort_by_key(|r| r.height);
    println!("rectangle list is: {:?}", rec_arr);

    println!("\nThe End ...\n");
}

#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

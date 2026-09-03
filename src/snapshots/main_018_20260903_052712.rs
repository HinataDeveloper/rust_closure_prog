// Date: Thu Sep 03 2026

// Project: Learning Chapter 13
// Goal: Using Interator
// Dependency: Without dependency

// rustc 1.100.0-nightly (5db7f4be8 2026-09-01)
// binary: rustc
// commit-hash: 5db7f4be8a36c1b8ae19299469e2be2b0f052c21
// commit-date: 2026-09-01
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

// Kernel Version: 7.1.12-200.fc44.x86_64
// Firmware Version: 71CN51WW(V1.21)

fn main() {
    println!("\n");

    let number_list = vec![1, 2, 3, 4, 5, 6, 7, 8, 9];
    let mut iter_one = number_list.iter();

    assert_eq!(iter_one.next(), Some(&1));
    assert_eq!(iter_one.next(), Some(&2));
    assert_eq!(iter_one.next(), Some(&3));
    assert_eq!(iter_one.next(), Some(&4));
    assert_eq!(iter_one.next(), Some(&5));
    assert_eq!(iter_one.next(), Some(&6));
    assert_eq!(iter_one.next(), Some(&7));
    assert_eq!(iter_one.next(), Some(&8));
    assert_eq!(iter_one.next(), Some(&9));
    assert_eq!(iter_one.next(), None);

    println!("all asserts passed ...");

    println!("\nThe End ...\n");
}

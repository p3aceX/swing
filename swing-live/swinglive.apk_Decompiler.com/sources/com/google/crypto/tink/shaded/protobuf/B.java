package com.google.crypto.tink.shaded.protobuf;

import java.io.IOException;

/* JADX INFO: loaded from: classes.dex */
public class B extends IOException {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f3723a;

    public static B a() {
        return new B("Protocol message contained an invalid tag (zero).");
    }

    public static B b() {
        return new B("Protocol message had invalid UTF-8.");
    }

    public static A c() {
        return new A("Protocol message tag had invalid wire type.");
    }

    public static B d() {
        return new B("CodedInputStream encountered a malformed varint.");
    }

    public static B e() {
        return new B("CodedInputStream encountered an embedded string or message which claimed to have negative size.");
    }

    public static B f() {
        return new B("Failed to parse the message.");
    }

    public static B g() {
        return new B("While parsing a protocol message, the input ended unexpectedly in the middle of a field.  This could mean either that the input has been truncated or that an embedded message misreported its own length.");
    }
}

package androidx.datastore.preferences.protobuf;

import java.io.IOException;

/* JADX INFO: renamed from: androidx.datastore.preferences.protobuf.y, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public class C0213y extends IOException {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f3037a;

    public static C0213y a() {
        return new C0213y("Protocol message had invalid UTF-8.");
    }

    public static C0212x b() {
        return new C0212x("Protocol message tag had invalid wire type.");
    }

    public static C0213y c() {
        return new C0213y("CodedInputStream encountered a malformed varint.");
    }

    public static C0213y d() {
        return new C0213y("CodedInputStream encountered an embedded string or message which claimed to have negative size.");
    }

    public static C0213y e() {
        return new C0213y("While parsing a protocol message, the input ended unexpectedly in the middle of a field.  This could mean either that the input has been truncated or that an embedded message misreported its own length.");
    }
}

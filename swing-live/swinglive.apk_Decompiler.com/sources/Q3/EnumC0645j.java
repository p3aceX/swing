package q3;

import o3.C0592H;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: q3.j, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0645j {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0592H f6300b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ EnumC0645j[] f6301c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ B3.b f6302d;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final short f6303a;

    static {
        EnumC0645j[] enumC0645jArr = {new EnumC0645j("SERVER_NAME", 0, (short) 0), new EnumC0645j("MAX_FRAGMENT_LENGTH", 1, (short) 1), new EnumC0645j("CLIENT_CERTIFICATE_URL", 2, (short) 2), new EnumC0645j("TRUSTED_CA_KEYS", 3, (short) 3), new EnumC0645j("TRUNCATED_HMAC", 4, (short) 4), new EnumC0645j("STATUS_REQUEST", 5, (short) 5), new EnumC0645j("ELLIPTIC_CURVES", 6, (short) 10), new EnumC0645j("EC_POINT_FORMAT", 7, (short) 11), new EnumC0645j("SIGNATURE_ALGORITHMS", 8, (short) 13)};
        f6301c = enumC0645jArr;
        f6302d = H0.a.z(enumC0645jArr);
        f6300b = new C0592H();
    }

    public EnumC0645j(String str, int i4, short s4) {
        this.f6303a = s4;
    }

    public static EnumC0645j valueOf(String str) {
        return (EnumC0645j) Enum.valueOf(EnumC0645j.class, str);
    }

    public static EnumC0645j[] values() {
        return (EnumC0645j[]) f6301c.clone();
    }
}

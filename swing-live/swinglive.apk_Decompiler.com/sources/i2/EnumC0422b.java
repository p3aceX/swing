package i2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: i2.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0422b {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final EnumC0422b f4489b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0422b f4490c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final EnumC0422b f4491d;
    public static final /* synthetic */ EnumC0422b[] e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ B3.b f4492f;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte f4493a;

    static {
        EnumC0422b enumC0422b = new EnumC0422b("STREAM_BEGIN", 0, (byte) 0);
        EnumC0422b enumC0422b2 = new EnumC0422b("STREAM_EOF", 1, (byte) 1);
        EnumC0422b enumC0422b3 = new EnumC0422b("STREAM_DRY", 2, (byte) 2);
        EnumC0422b enumC0422b4 = new EnumC0422b("SET_BUFFER_LENGTH", 3, (byte) 3);
        f4489b = enumC0422b4;
        EnumC0422b enumC0422b5 = new EnumC0422b("STREAM_IS_RECORDED", 4, (byte) 4);
        EnumC0422b enumC0422b6 = new EnumC0422b("PING_REQUEST", 5, (byte) 6);
        f4490c = enumC0422b6;
        EnumC0422b enumC0422b7 = new EnumC0422b("PONG_REPLY", 6, (byte) 7);
        f4491d = enumC0422b7;
        EnumC0422b[] enumC0422bArr = {enumC0422b, enumC0422b2, enumC0422b3, enumC0422b4, enumC0422b5, enumC0422b6, enumC0422b7, new EnumC0422b("BUFFER_EMPTY", 7, (byte) 31), new EnumC0422b("BUFFER_READY", 8, (byte) 32)};
        e = enumC0422bArr;
        f4492f = H0.a.z(enumC0422bArr);
    }

    public EnumC0422b(String str, int i4, byte b5) {
        this.f4493a = b5;
    }

    public static EnumC0422b valueOf(String str) {
        return (EnumC0422b) Enum.valueOf(EnumC0422b.class, str);
    }

    public static EnumC0422b[] values() {
        return (EnumC0422b[]) e.clone();
    }
}

package t2;

import o3.C0592H;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: t2.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0679d {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0592H f6570b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0679d f6571c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final EnumC0679d f6572d;
    public static final EnumC0679d e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final EnumC0679d f6573f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final EnumC0679d f6574m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final EnumC0679d f6575n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static final EnumC0679d f6576o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public static final EnumC0679d f6577p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public static final EnumC0679d f6578q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public static final EnumC0679d f6579r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public static final /* synthetic */ EnumC0679d[] f6580s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public static final /* synthetic */ B3.b f6581t;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6582a;

    static {
        EnumC0679d enumC0679d = new EnumC0679d("HANDSHAKE", 0, 0);
        f6571c = enumC0679d;
        EnumC0679d enumC0679d2 = new EnumC0679d("KEEP_ALIVE", 1, 1);
        f6572d = enumC0679d2;
        EnumC0679d enumC0679d3 = new EnumC0679d("ACK", 2, 2);
        e = enumC0679d3;
        EnumC0679d enumC0679d4 = new EnumC0679d("NAK", 3, 3);
        f6573f = enumC0679d4;
        EnumC0679d enumC0679d5 = new EnumC0679d("CONGESTION_WARNING", 4, 4);
        f6574m = enumC0679d5;
        EnumC0679d enumC0679d6 = new EnumC0679d("SHUTDOWN", 5, 5);
        f6575n = enumC0679d6;
        EnumC0679d enumC0679d7 = new EnumC0679d("ACK2", 6, 6);
        f6576o = enumC0679d7;
        EnumC0679d enumC0679d8 = new EnumC0679d("DROP_REQ", 7, 7);
        f6577p = enumC0679d8;
        EnumC0679d enumC0679d9 = new EnumC0679d("PEER_ERROR", 8, 8);
        f6578q = enumC0679d9;
        EnumC0679d enumC0679d10 = new EnumC0679d("USER_DEFINED", 9, 32767);
        EnumC0679d enumC0679d11 = new EnumC0679d("SUB_TYPE", 10, 0);
        f6579r = enumC0679d11;
        EnumC0679d[] enumC0679dArr = {enumC0679d, enumC0679d2, enumC0679d3, enumC0679d4, enumC0679d5, enumC0679d6, enumC0679d7, enumC0679d8, enumC0679d9, enumC0679d10, enumC0679d11};
        f6580s = enumC0679dArr;
        f6581t = H0.a.z(enumC0679dArr);
        f6570b = new C0592H();
    }

    public EnumC0679d(String str, int i4, int i5) {
        this.f6582a = i5;
    }

    public static EnumC0679d valueOf(String str) {
        return (EnumC0679d) Enum.valueOf(EnumC0679d.class, str);
    }

    public static EnumC0679d[] values() {
        return (EnumC0679d[]) f6580s.clone();
    }
}

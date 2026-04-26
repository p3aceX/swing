package o3;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class W {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0592H f6061b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final B3.b f6062c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final W f6063d;
    public static final /* synthetic */ W[] e;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6064a;

    static {
        W w4 = new W("SSL3", 0, 768);
        W w5 = new W("TLS10", 1, 769);
        W w6 = new W("TLS11", 2, 770);
        W w7 = new W("TLS12", 3, 771);
        f6063d = w7;
        W[] wArr = {w4, w5, w6, w7};
        e = wArr;
        B3.b bVarZ = H0.a.z(wArr);
        f6061b = new C0592H();
        f6062c = bVarZ;
    }

    public W(String str, int i4, int i5) {
        this.f6064a = i5;
    }

    public static W valueOf(String str) {
        return (W) Enum.valueOf(W.class, str);
    }

    public static W[] values() {
        return (W[]) e.clone();
    }
}

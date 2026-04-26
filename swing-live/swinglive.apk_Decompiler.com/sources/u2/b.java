package u2;

import o3.C0592H;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final C0592H f6647a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final /* synthetic */ b[] f6648b;

    static {
        b[] bVarArr = {new b("HS_V5_FLAG", 0), new b("HS_REQ", 1), new b("KM_REQ", 2), new b("CONFIG", 3), new b("HS_V5_MAGIC", 4)};
        f6648b = bVarArr;
        H0.a.z(bVarArr);
        f6647a = new C0592H();
    }

    public static b valueOf(String str) {
        return (b) Enum.valueOf(b.class, str);
    }

    public static b[] values() {
        return (b[]) f6648b.clone();
    }
}

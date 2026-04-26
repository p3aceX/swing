package u2;

import o3.C0592H;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: u2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0691a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0592H f6643b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0691a f6644c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ EnumC0691a[] f6645d;
    public static final /* synthetic */ B3.b e;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6646a;

    static {
        EnumC0691a enumC0691a = new EnumC0691a("NONE", 0, 0);
        f6644c = enumC0691a;
        EnumC0691a[] enumC0691aArr = {enumC0691a, new EnumC0691a("AES128", 1, 2), new EnumC0691a("AES192", 2, 3), new EnumC0691a("AES256", 3, 4)};
        f6645d = enumC0691aArr;
        e = H0.a.z(enumC0691aArr);
        f6643b = new C0592H();
    }

    public EnumC0691a(String str, int i4, int i5) {
        this.f6646a = i5;
    }

    public static EnumC0691a valueOf(String str) {
        return (EnumC0691a) Enum.valueOf(EnumC0691a.class, str);
    }

    public static EnumC0691a[] values() {
        return (EnumC0691a[]) f6645d.clone();
    }
}

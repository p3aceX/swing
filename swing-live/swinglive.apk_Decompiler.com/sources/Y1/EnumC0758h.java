package y1;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: y1.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0758h {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final EnumC0758h f6856a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final EnumC0758h f6857b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0758h f6858c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ EnumC0758h[] f6859d;

    static {
        EnumC0758h enumC0758h = new EnumC0758h("H264", 0);
        f6856a = enumC0758h;
        EnumC0758h enumC0758h2 = new EnumC0758h("H265", 1);
        f6857b = enumC0758h2;
        EnumC0758h enumC0758h3 = new EnumC0758h("AV1", 2);
        f6858c = enumC0758h3;
        EnumC0758h[] enumC0758hArr = {enumC0758h, enumC0758h2, enumC0758h3};
        f6859d = enumC0758hArr;
        H0.a.z(enumC0758hArr);
    }

    public static EnumC0758h valueOf(String str) {
        return (EnumC0758h) Enum.valueOf(EnumC0758h.class, str);
    }

    public static EnumC0758h[] values() {
        return (EnumC0758h[]) f6859d.clone();
    }
}

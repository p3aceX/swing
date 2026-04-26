package androidx.lifecycle;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: androidx.lifecycle.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0222h {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final EnumC0222h f3067a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final EnumC0222h f3068b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0222h f3069c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final EnumC0222h f3070d;
    public static final EnumC0222h e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ EnumC0222h[] f3071f;

    static {
        EnumC0222h enumC0222h = new EnumC0222h("DESTROYED", 0);
        f3067a = enumC0222h;
        EnumC0222h enumC0222h2 = new EnumC0222h("INITIALIZED", 1);
        f3068b = enumC0222h2;
        EnumC0222h enumC0222h3 = new EnumC0222h("CREATED", 2);
        f3069c = enumC0222h3;
        EnumC0222h enumC0222h4 = new EnumC0222h("STARTED", 3);
        f3070d = enumC0222h4;
        EnumC0222h enumC0222h5 = new EnumC0222h("RESUMED", 4);
        e = enumC0222h5;
        f3071f = new EnumC0222h[]{enumC0222h, enumC0222h2, enumC0222h3, enumC0222h4, enumC0222h5};
    }

    public static EnumC0222h valueOf(String str) {
        return (EnumC0222h) Enum.valueOf(EnumC0222h.class, str);
    }

    public static EnumC0222h[] values() {
        return (EnumC0222h[]) f3071f.clone();
    }
}

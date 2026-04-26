package androidx.lifecycle;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: androidx.lifecycle.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0221g {
    private static final /* synthetic */ EnumC0221g[] $VALUES;
    public static final C0219e Companion;
    public static final EnumC0221g ON_ANY;
    public static final EnumC0221g ON_CREATE;
    public static final EnumC0221g ON_DESTROY;
    public static final EnumC0221g ON_PAUSE;
    public static final EnumC0221g ON_RESUME;
    public static final EnumC0221g ON_START;
    public static final EnumC0221g ON_STOP;

    static {
        EnumC0221g enumC0221g = new EnumC0221g("ON_CREATE", 0);
        ON_CREATE = enumC0221g;
        EnumC0221g enumC0221g2 = new EnumC0221g("ON_START", 1);
        ON_START = enumC0221g2;
        EnumC0221g enumC0221g3 = new EnumC0221g("ON_RESUME", 2);
        ON_RESUME = enumC0221g3;
        EnumC0221g enumC0221g4 = new EnumC0221g("ON_PAUSE", 3);
        ON_PAUSE = enumC0221g4;
        EnumC0221g enumC0221g5 = new EnumC0221g("ON_STOP", 4);
        ON_STOP = enumC0221g5;
        EnumC0221g enumC0221g6 = new EnumC0221g("ON_DESTROY", 5);
        ON_DESTROY = enumC0221g6;
        EnumC0221g enumC0221g7 = new EnumC0221g("ON_ANY", 6);
        ON_ANY = enumC0221g7;
        $VALUES = new EnumC0221g[]{enumC0221g, enumC0221g2, enumC0221g3, enumC0221g4, enumC0221g5, enumC0221g6, enumC0221g7};
        Companion = new C0219e();
    }

    public static EnumC0221g valueOf(String str) {
        return (EnumC0221g) Enum.valueOf(EnumC0221g.class, str);
    }

    public static EnumC0221g[] values() {
        return (EnumC0221g[]) $VALUES.clone();
    }

    public final EnumC0222h a() {
        switch (AbstractC0220f.f3066a[ordinal()]) {
            case 1:
            case 2:
                return EnumC0222h.f3069c;
            case 3:
            case 4:
                return EnumC0222h.f3070d;
            case 5:
                return EnumC0222h.e;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                return EnumC0222h.f3067a;
            default:
                throw new IllegalArgumentException(this + " has no target state");
        }
    }
}

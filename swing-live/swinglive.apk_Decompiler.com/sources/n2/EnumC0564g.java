package n2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: n2.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0564g {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final EnumC0564g f5886b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0564g f5887c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final EnumC0564g f5888d;
    public static final /* synthetic */ EnumC0564g[] e;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte f5889a;

    static {
        EnumC0564g enumC0564g = new EnumC0564g("AUDIO", 0, (byte) -64);
        f5886b = enumC0564g;
        EnumC0564g enumC0564g2 = new EnumC0564g("VIDEO", 1, (byte) -32);
        f5887c = enumC0564g2;
        EnumC0564g enumC0564g3 = new EnumC0564g("METADATA", 2, (byte) -4);
        EnumC0564g enumC0564g4 = new EnumC0564g("PRIVATE_STREAM_1", 3, (byte) -67);
        f5888d = enumC0564g4;
        EnumC0564g[] enumC0564gArr = {enumC0564g, enumC0564g2, enumC0564g3, enumC0564g4, new EnumC0564g("EXTENDED_STREAM", 4, (byte) -3)};
        e = enumC0564gArr;
        H0.a.z(enumC0564gArr);
    }

    public EnumC0564g(String str, int i4, byte b5) {
        this.f5889a = b5;
    }

    public static EnumC0564g valueOf(String str) {
        return (EnumC0564g) Enum.valueOf(EnumC0564g.class, str);
    }

    public static EnumC0564g[] values() {
        return (EnumC0564g[]) e.clone();
    }
}

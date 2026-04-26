package z1;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: z1.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0787b {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final EnumC0787b f6986b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0787b f6987c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final EnumC0787b f6988d;
    public static final /* synthetic */ EnumC0787b[] e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ B3.b f6989f;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6990a;

    static {
        EnumC0787b enumC0787b = new EnumC0787b("RESERVED", 0, 0);
        f6986b = enumC0787b;
        EnumC0787b enumC0787b2 = new EnumC0787b("SEQUENCE_HEADER", 1, 1);
        f6987c = enumC0787b2;
        EnumC0787b enumC0787b3 = new EnumC0787b("TEMPORAL_DELIMITER", 2, 2);
        f6988d = enumC0787b3;
        EnumC0787b[] enumC0787bArr = {enumC0787b, enumC0787b2, enumC0787b3, new EnumC0787b("FRAME_HEADER", 3, 3), new EnumC0787b("TILE_GROUP", 4, 4), new EnumC0787b("METADATA", 5, 5), new EnumC0787b("FRAME", 6, 6), new EnumC0787b("REDUNDANT_FRAME_HEADER", 7, 7), new EnumC0787b("TILE_LIST", 8, 8), new EnumC0787b("PADDING", 9, 15)};
        e = enumC0787bArr;
        f6989f = H0.a.z(enumC0787bArr);
    }

    public EnumC0787b(String str, int i4, int i5) {
        this.f6990a = i5;
    }

    public static EnumC0787b valueOf(String str) {
        return (EnumC0787b) Enum.valueOf(EnumC0787b.class, str);
    }

    public static EnumC0787b[] values() {
        return (EnumC0787b[]) e.clone();
    }
}

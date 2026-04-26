package a2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: a2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0188a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ EnumC0188a[] f2633a;

    static {
        EnumC0188a[] enumC0188aArr = {new EnumC0188a("PCM", 0), new EnumC0188a("ADPCM", 1), new EnumC0188a("MP3", 2), new EnumC0188a("PCM_LE", 3), new EnumC0188a("NELLYMOSER_16K", 4), new EnumC0188a("NELLYMOSER_8K", 5), new EnumC0188a("NELLYMOSER", 6), new EnumC0188a("G711_A", 7), new EnumC0188a("G711_MU", 8), new EnumC0188a("EX_HEADER", 9), new EnumC0188a("AAC", 10), new EnumC0188a("SPEEX", 11), new EnumC0188a("MP3_8K", 12), new EnumC0188a("DEVICE_SPECIFIC", 13), new EnumC0188a("AC3", 14), new EnumC0188a("EAC3", 15), new EnumC0188a("OPUS", 16), new EnumC0188a("MP3_CC", 17), new EnumC0188a("FLAC", 18), new EnumC0188a("AAC_CC", 19)};
        f2633a = enumC0188aArr;
        H0.a.z(enumC0188aArr);
    }

    public static EnumC0188a valueOf(String str) {
        return (EnumC0188a) Enum.valueOf(EnumC0188a.class, str);
    }

    public static EnumC0188a[] values() {
        return (EnumC0188a[]) f2633a.clone();
    }
}

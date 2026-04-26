package c3;

/* JADX INFO: loaded from: classes.dex */
public enum b {
    off("off"),
    fast("fast"),
    highQuality("highQuality"),
    minimal("minimal"),
    zeroShutterLag("zeroShutterLag");


    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f3306a;

    b(String str) {
        this.f3306a = str;
    }

    @Override // java.lang.Enum
    public final String toString() {
        return this.f3306a;
    }
}

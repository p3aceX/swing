package T2;

/* JADX INFO: renamed from: T2.j, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0165j implements O2.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f1975a = false;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0164i f1976b;

    public C0165j(C0164i c0164i) {
        this.f1976b = c0164i;
    }

    @Override // O2.p
    public final boolean b(int i4, String[] strArr, int[] iArr) {
        if (this.f1975a || i4 != 9796) {
            return false;
        }
        this.f1975a = true;
        int length = iArr.length;
        C0164i c0164i = this.f1976b;
        if (length == 0 || iArr[0] != 0) {
            c0164i.a("CameraAccessDenied", "Camera access permission was denied.");
            return true;
        }
        if (iArr.length <= 1 || iArr[1] == 0) {
            c0164i.a(null, null);
            return true;
        }
        c0164i.a("AudioAccessDenied", "Audio access permission was denied.");
        return true;
    }
}

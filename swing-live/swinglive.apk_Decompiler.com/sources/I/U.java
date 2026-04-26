package I;

import java.io.File;

/* JADX INFO: loaded from: classes.dex */
public final class U extends J3.j implements I3.l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final U f614a = new U(1);

    @Override // I3.l
    public final Object invoke(Object obj) {
        File file = (File) obj;
        J3.i.e(file, "it");
        String absolutePath = file.getCanonicalFile().getAbsolutePath();
        J3.i.d(absolutePath, "file.canonicalFile.absolutePath");
        return new l0(absolutePath);
    }
}

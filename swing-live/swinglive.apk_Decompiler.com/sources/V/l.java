package V;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f2165a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f2166b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final long f2167c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final long f2168d;

    public l(int i4, int i5, long j4, long j5) {
        this.f2165a = i4;
        this.f2166b = i5;
        this.f2167c = j4;
        this.f2168d = j5;
    }

    public static l a(File file) throws IOException {
        DataInputStream dataInputStream = new DataInputStream(new FileInputStream(file));
        try {
            l lVar = new l(dataInputStream.readInt(), dataInputStream.readInt(), dataInputStream.readLong(), dataInputStream.readLong());
            dataInputStream.close();
            return lVar;
        } finally {
        }
    }

    public final void b(File file) throws IOException {
        file.delete();
        DataOutputStream dataOutputStream = new DataOutputStream(new FileOutputStream(file));
        try {
            dataOutputStream.writeInt(this.f2165a);
            dataOutputStream.writeInt(this.f2166b);
            dataOutputStream.writeLong(this.f2167c);
            dataOutputStream.writeLong(this.f2168d);
            dataOutputStream.close();
        } catch (Throwable th) {
            try {
                dataOutputStream.close();
            } catch (Throwable th2) {
                th.addSuppressed(th2);
            }
            throw th;
        }
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj != null && (obj instanceof l)) {
            l lVar = (l) obj;
            if (this.f2166b == lVar.f2166b && this.f2167c == lVar.f2167c && this.f2165a == lVar.f2165a && this.f2168d == lVar.f2168d) {
                return true;
            }
        }
        return false;
    }

    public final int hashCode() {
        return Objects.hash(Integer.valueOf(this.f2166b), Long.valueOf(this.f2167c), Integer.valueOf(this.f2165a), Long.valueOf(this.f2168d));
    }
}

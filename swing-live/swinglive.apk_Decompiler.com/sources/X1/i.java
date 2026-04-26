package X1;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import y1.AbstractC0752b;

/* JADX INFO: loaded from: classes.dex */
public final class i extends b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public String f2397a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f2398b;

    public i(String str) {
        J3.i.e(str, "value");
        this.f2397a = str;
        byte[] bytes = str.getBytes(P3.a.f1492a);
        J3.i.d(bytes, "getBytes(...)");
        this.f2398b = bytes.length + 2;
    }

    @Override // X1.b
    public final int a() {
        return this.f2398b;
    }

    @Override // X1.b
    public final j b() {
        return j.f2401d;
    }

    @Override // X1.b
    public final void c(InputStream inputStream) throws IOException {
        J3.i.e(inputStream, "input");
        int iG = AbstractC0752b.g(inputStream);
        this.f2398b = iG;
        byte[] bArr = new byte[iG];
        this.f2398b = iG + 2;
        AbstractC0752b.i(inputStream, bArr);
        this.f2397a = new String(bArr, P3.a.f1492a);
    }

    @Override // X1.b
    public final void d(ByteArrayOutputStream byteArrayOutputStream) throws IOException {
        AbstractC0752b.r(byteArrayOutputStream, this.f2398b - 2);
        byte[] bytes = this.f2397a.getBytes(P3.a.f1492a);
        J3.i.d(bytes, "getBytes(...)");
        byteArrayOutputStream.write(bytes);
    }

    public final String toString() {
        return B1.a.m("AmfString value: ", this.f2397a);
    }

    public /* synthetic */ i() {
        this("");
    }
}

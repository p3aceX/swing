package X1;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

/* JADX INFO: loaded from: classes.dex */
public final class a extends b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f2386a;

    public a(boolean z4) {
        this.f2386a = z4;
    }

    @Override // X1.b
    public final int a() {
        return 1;
    }

    @Override // X1.b
    public final j b() {
        return j.f2400c;
    }

    @Override // X1.b
    public final void c(InputStream inputStream) {
        J3.i.e(inputStream, "input");
        this.f2386a = inputStream.read() != 0;
    }

    @Override // X1.b
    public final void d(ByteArrayOutputStream byteArrayOutputStream) throws IOException {
        byteArrayOutputStream.write(this.f2386a ? 1 : 0);
    }

    public final String toString() {
        return "AmfBoolean value: " + this.f2386a;
    }
}

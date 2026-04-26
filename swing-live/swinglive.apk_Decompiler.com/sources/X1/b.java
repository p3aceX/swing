package X1;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

/* JADX INFO: loaded from: classes.dex */
public abstract class b {
    public abstract int a();

    public abstract j b();

    public abstract void c(InputStream inputStream);

    public abstract void d(ByteArrayOutputStream byteArrayOutputStream);

    public final void e(ByteArrayOutputStream byteArrayOutputStream) throws IOException {
        byteArrayOutputStream.write(b().f2412a);
    }
}

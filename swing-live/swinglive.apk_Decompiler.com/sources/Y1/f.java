package Y1;

import J3.i;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public class f extends b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final HashMap f2506a;

    public f(HashMap map) {
        this.f2506a = map;
    }

    @Override // Y1.b
    public int a() {
        throw new H3.a();
    }

    @Override // Y1.b
    public h b() {
        return h.f2515p;
    }

    @Override // Y1.b
    public void c(InputStream inputStream) {
        i.e(inputStream, "input");
        throw new H3.a();
    }

    @Override // Y1.b
    public void d(ByteArrayOutputStream byteArrayOutputStream) {
        throw new H3.a();
    }

    public final b e(String str) {
        for (Map.Entry entry : this.f2506a.entrySet()) {
            if (i.a(((g) entry.getKey()).f2507a, str)) {
                return (b) entry.getValue();
            }
        }
        return null;
    }
}

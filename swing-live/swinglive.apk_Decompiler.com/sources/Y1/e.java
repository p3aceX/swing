package Y1;

import J3.i;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;

/* JADX INFO: loaded from: classes.dex */
public final class e extends b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f2505a;

    @Override // Y1.b
    public final int a() {
        switch (this.f2505a) {
            case 0:
                return 0;
            case 1:
                throw new H3.a();
            case 2:
                return 0;
            case 3:
                return 0;
            default:
                return 0;
        }
    }

    @Override // Y1.b
    public final h b() {
        switch (this.f2505a) {
            case 0:
                return h.e;
            case 1:
                return h.f2511f;
            case 2:
                return h.f2509c;
            case 3:
                return h.f2510d;
            default:
                return h.f2508b;
        }
    }

    @Override // Y1.b
    public final void c(InputStream inputStream) {
        switch (this.f2505a) {
            case 0:
                i.e(inputStream, "input");
                return;
            case 1:
                i.e(inputStream, "input");
                throw new H3.a();
            case 2:
                i.e(inputStream, "input");
                return;
            case 3:
                i.e(inputStream, "input");
                return;
            default:
                i.e(inputStream, "input");
                return;
        }
    }

    @Override // Y1.b
    public final void d(ByteArrayOutputStream byteArrayOutputStream) {
        switch (this.f2505a) {
            case 0:
                return;
            case 1:
                throw new H3.a();
            case 2:
            case 3:
            default:
                return;
        }
    }

    private final void e(ByteArrayOutputStream byteArrayOutputStream) {
    }

    private final void f(ByteArrayOutputStream byteArrayOutputStream) {
    }

    private final void g(ByteArrayOutputStream byteArrayOutputStream) {
    }

    private final void h(ByteArrayOutputStream byteArrayOutputStream) {
    }
}

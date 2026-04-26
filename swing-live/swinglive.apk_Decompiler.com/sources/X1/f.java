package X1;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;

/* JADX INFO: loaded from: classes.dex */
public final class f extends b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f2393a;

    public /* synthetic */ f(int i4) {
        this.f2393a = i4;
    }

    @Override // X1.b
    public final int a() {
        switch (this.f2393a) {
        }
        return 0;
    }

    @Override // X1.b
    public final j b() {
        switch (this.f2393a) {
            case 0:
                return j.f2402f;
            case 1:
                return j.f2403m;
            default:
                return j.f2408r;
        }
    }

    @Override // X1.b
    public final void c(InputStream inputStream) {
        switch (this.f2393a) {
            case 0:
                J3.i.e(inputStream, "input");
                break;
            case 1:
                J3.i.e(inputStream, "input");
                break;
            default:
                J3.i.e(inputStream, "input");
                break;
        }
    }

    @Override // X1.b
    public final void d(ByteArrayOutputStream byteArrayOutputStream) {
        int i4 = this.f2393a;
    }

    public final String toString() {
        switch (this.f2393a) {
            case 0:
                return "AmfNull";
            case 1:
                return "AmfUndefined";
            default:
                return "AmfUnsupported";
        }
    }

    private final void f(ByteArrayOutputStream byteArrayOutputStream) {
    }

    private final void g(ByteArrayOutputStream byteArrayOutputStream) {
    }

    private final void h(ByteArrayOutputStream byteArrayOutputStream) {
    }
}

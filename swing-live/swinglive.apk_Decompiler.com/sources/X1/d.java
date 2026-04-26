package X1;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.LinkedHashMap;
import y1.AbstractC0752b;

/* JADX INFO: loaded from: classes.dex */
public final class d extends h {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final LinkedHashMap f2388c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f2389d;

    public d() {
        LinkedHashMap linkedHashMap = new LinkedHashMap();
        super(linkedHashMap);
        this.f2388c = linkedHashMap;
        this.f2396b += 4;
    }

    @Override // X1.h, X1.b
    public final j b() {
        return j.f2404n;
    }

    @Override // X1.h, X1.b
    public final void c(InputStream inputStream) throws IOException {
        J3.i.e(inputStream, "input");
        this.f2389d = AbstractC0752b.h(inputStream);
        super.c(inputStream);
        this.f2396b += 4;
    }

    @Override // X1.h, X1.b
    public final void d(ByteArrayOutputStream byteArrayOutputStream) throws IOException {
        AbstractC0752b.s(byteArrayOutputStream, this.f2389d);
        super.d(byteArrayOutputStream);
    }

    @Override // X1.h
    public final void g(String str, double d5) {
        super.g(str, d5);
        this.f2389d = this.f2388c.size();
    }

    @Override // X1.h
    public final void h(String str, String str2) {
        throw null;
    }

    @Override // X1.h
    public final String toString() {
        return "AmfEcmaArray length: " + this.f2389d + ", properties: " + this.f2388c;
    }
}

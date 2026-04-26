package h2;

import g2.f;
import g2.o;

/* JADX INFO: renamed from: h2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0412a extends o {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public String f4413c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4414d;
    public int e;

    public AbstractC0412a(String str, int i4, int i5, int i6, f fVar) {
        super(fVar);
        this.f4413c = str;
        this.f4414d = i4;
        a().f4373c = this.e;
        a().f4372b = i5;
        a().e = i6;
    }

    @Override // g2.o
    public final int b() {
        return this.e;
    }

    public abstract String h();

    public abstract String i();

    public abstract int j();
}

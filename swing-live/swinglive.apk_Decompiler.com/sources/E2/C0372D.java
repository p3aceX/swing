package e2;

import y1.AbstractC0752b;

/* JADX INFO: renamed from: e2.D, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class C0372D implements I3.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f4016a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f4017b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ Object f4018c;

    public /* synthetic */ C0372D(int i4, Object obj, Object obj2) {
        this.f4016a = i4;
        this.f4018c = obj;
        this.f4017b = obj2;
    }

    @Override // I3.a
    public final Object a() {
        switch (this.f4016a) {
            case 0:
                ((L) this.f4018c).f4048a.a("Error configure stream, ".concat(AbstractC0752b.q((Throwable) this.f4017b)));
                break;
            case 1:
                ((Q) this.f4018c).f76a.a("Error send packet, ".concat(AbstractC0752b.q((Throwable) this.f4017b)));
                break;
            case 2:
                g2.j jVar = new g2.j((g2.f) this.f4018c);
                g2.o oVar = (g2.o) this.f4017b;
                jVar.f4374d = oVar.c();
                jVar.f4373c = oVar.b();
                break;
            case 3:
                ((r2.r) this.f4018c).f6388a.a("Error configure stream, " + ((u2.c) this.f4017b).f6655m.name());
                break;
            case 4:
                ((r2.r) this.f4018c).f6388a.a("Error configure stream, ".concat(AbstractC0752b.q((Throwable) this.f4017b)));
                break;
            default:
                ((r2.x) this.f4018c).f76a.a("Error send packet, ".concat(AbstractC0752b.q((Throwable) this.f4017b)));
                break;
        }
        return w3.i.f6729a;
    }
}

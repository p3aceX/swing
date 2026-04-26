package X;

import android.os.Trace;
import androidx.recyclerview.widget.RecyclerView;
import java.util.ArrayList;
import java.util.Collections;
import java.util.concurrent.TimeUnit;

/* JADX INFO: renamed from: X.j, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class RunnableC0179j implements Runnable {
    public static final ThreadLocal e = new ThreadLocal();

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final M1.f f2354f = new M1.f(1);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public ArrayList f2355a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public long f2356b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public long f2357c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public ArrayList f2358d;

    public final void a(RecyclerView recyclerView, int i4, int i5) {
        if (recyclerView.f3178s && this.f2356b == 0) {
            this.f2356b = recyclerView.getNanoTime();
            recyclerView.post(this);
        }
        C0177h c0177h = recyclerView.f3160c0;
        c0177h.f2347a = i4;
        c0177h.f2348b = i5;
    }

    public final void b(long j4) {
        C0178i c0178i;
        RecyclerView recyclerView;
        ArrayList arrayList = this.f2355a;
        int size = arrayList.size();
        int i4 = 0;
        for (int i5 = 0; i5 < size; i5++) {
            RecyclerView recyclerView2 = (RecyclerView) arrayList.get(i5);
            if (recyclerView2.getWindowVisibility() == 0) {
                C0177h c0177h = recyclerView2.f3160c0;
                c0177h.f2349c = 0;
                i4 += c0177h.f2349c;
            }
        }
        ArrayList arrayList2 = this.f2358d;
        arrayList2.ensureCapacity(i4);
        for (int i6 = 0; i6 < size; i6++) {
            RecyclerView recyclerView3 = (RecyclerView) arrayList.get(i6);
            if (recyclerView3.getWindowVisibility() == 0) {
                C0177h c0177h2 = recyclerView3.f3160c0;
                Math.abs(c0177h2.f2347a);
                Math.abs(c0177h2.f2348b);
                if (c0177h2.f2349c * 2 > 0) {
                    if (arrayList2.size() <= 0) {
                        arrayList2.add(new C0178i());
                    }
                    throw null;
                }
            }
        }
        Collections.sort(arrayList2, f2354f);
        if (arrayList2.size() <= 0 || (recyclerView = (c0178i = (C0178i) arrayList2.get(0)).f2353d) == null) {
            return;
        }
        int i7 = c0178i.e;
        if (recyclerView.f3161d.L() > 0) {
            RecyclerView.j(recyclerView.f3161d.K(0));
            throw null;
        }
        J1.c cVar = recyclerView.f3155a;
        try {
            recyclerView.f3135C++;
            cVar.e(i7);
            throw null;
        } catch (Throwable th) {
            int i8 = recyclerView.f3135C - 1;
            recyclerView.f3135C = i8;
            if (i8 < 1) {
                recyclerView.f3135C = 0;
            }
            throw th;
        }
    }

    @Override // java.lang.Runnable
    public final void run() {
        try {
            int i4 = w.f.f6682a;
            Trace.beginSection("RV Prefetch");
            ArrayList arrayList = this.f2355a;
            if (arrayList.isEmpty()) {
                this.f2356b = 0L;
                Trace.endSection();
                return;
            }
            int size = arrayList.size();
            long jMax = 0;
            for (int i5 = 0; i5 < size; i5++) {
                RecyclerView recyclerView = (RecyclerView) arrayList.get(i5);
                if (recyclerView.getWindowVisibility() == 0) {
                    jMax = Math.max(recyclerView.getDrawingTime(), jMax);
                }
            }
            if (jMax == 0) {
                this.f2356b = 0L;
                Trace.endSection();
            } else {
                b(TimeUnit.MILLISECONDS.toNanos(jMax) + this.f2357c);
                this.f2356b = 0L;
                Trace.endSection();
            }
        } catch (Throwable th) {
            this.f2356b = 0L;
            int i6 = w.f.f6682a;
            Trace.endSection();
            throw th;
        }
    }
}

package L3;

import J3.i;
import java.util.Random;
import java.util.concurrent.ThreadLocalRandom;

/* JADX INFO: loaded from: classes.dex */
public final class a extends K3.a {
    @Override // K3.d
    public final int c(int i4, int i5) {
        return ThreadLocalRandom.current().nextInt(i4, i5);
    }

    @Override // K3.a
    public final Random d() {
        ThreadLocalRandom threadLocalRandomCurrent = ThreadLocalRandom.current();
        i.d(threadLocalRandomCurrent, "current(...)");
        return threadLocalRandomCurrent;
    }
}

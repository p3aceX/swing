package b4;

import K.j;
import X.N;
import d4.e;
import d4.f;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.net.URL;
import java.security.AccessController;
import java.security.PrivilegedAction;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.ServiceConfigurationError;
import java.util.ServiceLoader;
import java.util.concurrent.LinkedBlockingQueue;

/* JADX INFO: loaded from: classes.dex */
public abstract class d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static volatile int f3289a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final d4.c f3290b = new d4.c(1);

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final d4.c f3291c = new d4.c(0);

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static volatile d4.c f3292d;
    public static final String[] e;

    static {
        String property;
        try {
            property = System.getProperty("slf4j.detectLoggerNameMismatch");
        } catch (SecurityException unused) {
            property = null;
        }
        if (property != null) {
            property.equalsIgnoreCase("true");
        }
        e = new String[]{"2.0"};
    }

    public static ArrayList a() {
        ArrayList arrayList = new ArrayList();
        final ClassLoader classLoader = d.class.getClassLoader();
        String property = System.getProperty("slf4j.provider");
        d4.c cVar = null;
        if (property != null && !property.isEmpty()) {
            try {
                String str = "Attempting to load provider \"" + property + "\" specified via \"slf4j.provider\" system property";
                int i4 = d4.d.f3961a;
                if (j.b(2) >= j.b(d4.d.f3962b)) {
                    d4.d.b().println("SLF4J(I): " + str);
                }
                cVar = (d4.c) classLoader.loadClass(property).getConstructor(new Class[0]).newInstance(new Object[0]);
            } catch (ClassCastException e4) {
                d4.d.a("Specified SLF4JServiceProvider (" + property + ") does not implement SLF4JServiceProvider interface", e4);
            } catch (ClassNotFoundException e5) {
                e = e5;
                d4.d.a("Failed to instantiate the specified SLF4JServiceProvider (" + property + ")", e);
            } catch (IllegalAccessException e6) {
                e = e6;
                d4.d.a("Failed to instantiate the specified SLF4JServiceProvider (" + property + ")", e);
            } catch (InstantiationException e7) {
                e = e7;
                d4.d.a("Failed to instantiate the specified SLF4JServiceProvider (" + property + ")", e);
            } catch (NoSuchMethodException e8) {
                e = e8;
                d4.d.a("Failed to instantiate the specified SLF4JServiceProvider (" + property + ")", e);
            } catch (InvocationTargetException e9) {
                e = e9;
                d4.d.a("Failed to instantiate the specified SLF4JServiceProvider (" + property + ")", e);
            }
        }
        if (cVar != null) {
            arrayList.add(cVar);
            return arrayList;
        }
        Iterator it = (System.getSecurityManager() == null ? ServiceLoader.load(d4.c.class, classLoader) : (ServiceLoader) AccessController.doPrivileged(new PrivilegedAction() { // from class: b4.c
            @Override // java.security.PrivilegedAction
            public final Object run() {
                return ServiceLoader.load(d4.c.class, classLoader);
            }
        })).iterator();
        while (it.hasNext()) {
            try {
                arrayList.add((d4.c) it.next());
            } catch (ServiceConfigurationError e10) {
                String str2 = "A service provider failed to instantiate:\n" + e10.getMessage();
                d4.d.b().println("SLF4J(E): " + str2);
            }
        }
        return arrayList;
    }

    public static b b() {
        d4.c cVar;
        a aVar;
        if (f3289a == 0) {
            synchronized (d.class) {
                try {
                    if (f3289a == 0) {
                        f3289a = 1;
                        c();
                    }
                } finally {
                }
            }
        }
        int i4 = f3289a;
        if (i4 == 1) {
            cVar = f3290b;
        } else {
            if (i4 == 2) {
                throw new IllegalStateException("org.slf4j.LoggerFactory in failed state. Original exception was thrown EARLIER. See also https://www.slf4j.org/codes.html#unsuccessfulInit");
            }
            if (i4 == 3) {
                cVar = f3292d;
            } else {
                if (i4 != 4) {
                    throw new IllegalStateException("Unreachable code");
                }
                cVar = f3291c;
            }
        }
        switch (cVar.f3959a) {
            case 0:
                aVar = (N) cVar.f3960b;
                break;
            default:
                aVar = (f) cVar.f3960b;
                break;
        }
        return aVar.c();
    }

    public static final void c() {
        try {
            ArrayList arrayListA = a();
            g(arrayListA);
            if (arrayListA.isEmpty()) {
                f3289a = 4;
                d4.d.c("No SLF4J providers were found.");
                d4.d.c("Defaulting to no-operation (NOP) logger implementation");
                d4.d.c("See https://www.slf4j.org/codes.html#noProviders for further details.");
                LinkedHashSet linkedHashSet = new LinkedHashSet();
                try {
                    ClassLoader classLoader = d.class.getClassLoader();
                    Enumeration<URL> systemResources = classLoader == null ? ClassLoader.getSystemResources("org/slf4j/impl/StaticLoggerBinder.class") : classLoader.getResources("org/slf4j/impl/StaticLoggerBinder.class");
                    while (systemResources.hasMoreElements()) {
                        linkedHashSet.add(systemResources.nextElement());
                    }
                } catch (IOException e4) {
                    d4.d.a("Error getting resources from path", e4);
                }
                f(linkedHashSet);
            } else {
                f3292d = (d4.c) arrayListA.get(0);
                f3292d.getClass();
                f3292d.getClass();
                f3289a = 3;
                e(arrayListA);
            }
            d();
            if (f3289a == 3) {
                try {
                    switch (f3292d.f3959a) {
                        case 0:
                            boolean z4 = false;
                            for (String str : e) {
                                if ("2.0.99".startsWith(str)) {
                                    z4 = true;
                                }
                            }
                            if (z4) {
                                return;
                            }
                            d4.d.c("The requested version 2.0.99 by your slf4j provider is not compatible with " + Arrays.asList(e).toString());
                            d4.d.c("See https://www.slf4j.org/codes.html#version_mismatch for further details.");
                            return;
                        default:
                            throw new UnsupportedOperationException();
                    }
                } catch (Throwable th) {
                    d4.d.a("Unexpected problem occurred during version sanity check", th);
                }
            }
        } catch (Exception e5) {
            f3289a = 2;
            d4.d.a("Failed to instantiate SLF4J LoggerFactory", e5);
            throw new IllegalStateException("Unexpected initialization failure", e5);
        }
    }

    public static void d() {
        d4.c cVar = f3290b;
        synchronized (cVar) {
            try {
                ((f) cVar.f3960b).f3968a = true;
                f fVar = (f) cVar.f3960b;
                fVar.getClass();
                for (e eVar : new ArrayList(fVar.f3969b.values())) {
                    eVar.getClass();
                    eVar.f3963a = b();
                }
            } catch (Throwable th) {
                throw th;
            }
        }
        LinkedBlockingQueue linkedBlockingQueue = ((f) f3290b.f3960b).f3970c;
        int size = linkedBlockingQueue.size();
        ArrayList<c4.b> arrayList = new ArrayList(128);
        int i4 = 0;
        while (linkedBlockingQueue.drainTo(arrayList, 128) != 0) {
            for (c4.b bVar : arrayList) {
                if (bVar != null) {
                    e eVar2 = bVar.f3309a;
                    eVar2.getClass();
                    if (eVar2.f3963a == null) {
                        throw new IllegalStateException("Delegate logger cannot be null at this state.");
                    }
                    if (!(eVar2.f3963a instanceof d4.b)) {
                        if (!eVar2.e()) {
                            d4.d.c("io.ktor.util.random");
                        } else if (eVar2.b() && eVar2.e()) {
                            try {
                                eVar2.f3965c.invoke(eVar2.f3963a, bVar);
                            } catch (IllegalAccessException | IllegalArgumentException | InvocationTargetException unused) {
                            }
                        }
                    }
                }
                int i5 = i4 + 1;
                if (i4 == 0) {
                    if (bVar.f3309a.e()) {
                        d4.d.c("A number (" + size + ") of logging calls during the initialization phase have been intercepted and are");
                        d4.d.c("now being replayed. These are subject to the filtering rules of the underlying logging system.");
                        d4.d.c("See also https://www.slf4j.org/codes.html#replay");
                    } else if (!(bVar.f3309a.f3963a instanceof d4.b)) {
                        d4.d.c("The following set of substitute loggers may have been accessed");
                        d4.d.c("during the initialization phase. Logging calls during this");
                        d4.d.c("phase were not honored. However, subsequent logging calls to these");
                        d4.d.c("loggers will work as normally expected.");
                        d4.d.c("See also https://www.slf4j.org/codes.html#substituteLogger");
                    }
                }
                i4 = i5;
            }
            arrayList.clear();
        }
        f fVar2 = (f) f3290b.f3960b;
        fVar2.f3969b.clear();
        fVar2.f3970c.clear();
    }

    public static void e(ArrayList arrayList) {
        if (arrayList.isEmpty()) {
            throw new IllegalStateException("No providers were found which is impossible after successful initialization.");
        }
        if (arrayList.size() > 1) {
            String str = "Actual provider is of type [" + arrayList.get(0) + "]";
            int i4 = d4.d.f3961a;
            if (j.b(2) >= j.b(d4.d.f3962b)) {
                d4.d.b().println("SLF4J(I): " + str);
                return;
            }
            return;
        }
        String str2 = "Connected with provider of type [" + ((d4.c) arrayList.get(0)).getClass().getName() + "]";
        int i5 = d4.d.f3961a;
        if (j.b(1) >= j.b(d4.d.f3962b)) {
            d4.d.b().println("SLF4J(D): " + str2);
        }
    }

    public static void f(LinkedHashSet linkedHashSet) {
        if (linkedHashSet.isEmpty()) {
            return;
        }
        d4.d.c("Class path contains SLF4J bindings targeting slf4j-api versions 1.7.x or earlier.");
        Iterator it = linkedHashSet.iterator();
        while (it.hasNext()) {
            d4.d.c("Ignoring binding found at [" + ((URL) it.next()) + "]");
        }
        d4.d.c("See https://www.slf4j.org/codes.html#ignoredBindings for an explanation.");
    }

    public static void g(ArrayList arrayList) {
        if (arrayList.size() > 1) {
            d4.d.c("Class path contains multiple SLF4J providers.");
            Iterator it = arrayList.iterator();
            while (it.hasNext()) {
                d4.d.c("Found provider [" + ((d4.c) it.next()) + "]");
            }
            d4.d.c("See https://www.slf4j.org/codes.html#multiple_bindings for an explanation.");
        }
    }
}

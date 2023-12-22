import pg_args
import pg_train
import pg_loadmode
import pg_loadmode1

if __name__ == '__main__':
    args = pg_args.arg_master()
    if args.choose == 'train':
        pg_train.train_mode(args)
    else:
        if args.Y_lb == 'T':
            pg_loadmode.load_mode1(args)
        else:
            pg_loadmode1.load_mode2(args)